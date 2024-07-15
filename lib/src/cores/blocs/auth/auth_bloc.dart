import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import '../../../index.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {

  final AuthRepository authRepository = AuthRepository();
  final UserRepository userRepository = UserRepository();
  final StoreRepository storeRepository = StoreRepository();

  AuthBloc() : super(AuthState()) {

    on<AuthUpdateState>((event, emit) async {
      emit(event.state);
    });

    on<AuthLogin>((event, emit) async {
      if (event.email.isEmpty || event.password.isEmpty) {
        return;
      }
      emit(AuthLoading());
      await authRepository.login(email: event.email, password: event.password).then((value) {
        if (value.statusCode == 200) {
          final data = value.data["data"];
          final box = Hive.box("storage");
          box.put("refresh_token", data["refresh_token"]);
          emit(
            state.copyWith(
              isAuthenticated: true, 
              token: data["token"], 
              user: User.fromJson(data)
            )
          );
          dio.interceptors.add(
            InterceptorsWrapper(
              onRequest: (options, handler) {
                final String? token = data["token"];
                if (token != null && token.isNotEmpty) {
                  options.headers['Authorization'] = 'Bearer $token';
                }
                return handler.next(options);
              },
            ),
          );
          GoRouter.of(rootNavigatorKey.currentContext!).goNamed(appRoutes.stores.name);
        }
      }).whenComplete(() => emit(state.copyWith()));
    });

    on<AuthRefreshToken>((event, emit) async {

      final box = Hive.box("storage");
      final token = box.get("refresh_token");
      final storeId = box.get("store_id");

      debugPrint("token: $token, storeId: $storeId");

      if (token == null || storeId == null) {
        if (token != null) box.delete("refresh_token");
        if (storeId != null) box.delete("store_id");
        emit(state.copyWith(isAuthenticated: false));
        return;
      }

      await authRepository.refreshToken().then((response) async {
        if (response.statusCode == 200) {

          final data = response.data["data"];
          box.put("refresh_token", data["refresh_token"]);
          dio.interceptors.add(
            InterceptorsWrapper(
              onRequest: (options, handler) {
                final String? nt = data["token"];
                if (nt != null && nt.isNotEmpty) {
                  options.headers['Authorization'] = 'Bearer $nt';
                }
                return handler.next(options);
              },
            ),
          );

          await userRepository.getUser("${data["user_id"]}").then((res) async {
            debugPrint(res.toString());
            if (res.statusCode == 200) {
              final dataUser = res.data["data"];
              await storeRepository.getStore("$storeId").then((res2) {
                if (res2.statusCode == 200) {
                  final dataStore = res2.data["data"];
                  box.put("store_id", dataStore["id"]);
                  GoRouter.of(rootNavigatorKey.currentContext!).goNamed(appRoutes.dashboard.name);
                  emit(
                    state.copyWith(
                      isAuthenticated: true, 
                      token: data["token"],
                      user: User.fromJson(dataUser),
                      store: Store.fromJson(dataStore)
                    )
                  );
                }
              });
            }
          });
        }

        if (response.statusCode! >= 400 && response.statusCode! < 500) {
          box.delete("refresh_token");
          box.delete("store_id");
        }

      }).whenComplete(() => emit(state.copyWith()));
      
    });

    on<AuthRegister>((event, emit) async {
      emit(AuthRegisterLoading());
      await authRepository.register(
        name: event.name, 
        email: event.email, 
        phone: event.phone,
        password: event.password,
        confirmPassword: event.confirmPassword
      ).whenComplete(() => emit(state.copyWith()));
    });

    on<AuthRequestResetPassword>((event, emit) async {
      emit(AuthRequestResetPasswordLoading());
      await authRepository.forgotPassword(email: event.email).whenComplete(() => emit(state.copyWith()));
    });

    on<AuthLogout>((event, emit) async {
      
      showModalLoader();

      final box = Hive.box("storage");
      box.delete("refresh_token");
      box.delete("store_id");
      emit(
        state.copyWith(
          isAuthenticated: false,
          token: "",
          user: null
        )          
      );
      dio.interceptors.remove(InterceptorsWrapper());
      await Future.delayed(const Duration(seconds: 1));
      rootNavigatorKey.currentState?.pop();
      GoRouter.of(rootNavigatorKey.currentContext!).goNamed(appRoutes.login.name);
    });
  }
}
