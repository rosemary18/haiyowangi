part of 'auth_bloc.dart';

final class AuthState {

  bool? isAuthenticated;
  String token;
  UserModel? user;
  StoreModel? store;
  int unreadNotification;

  AuthState({
    this.isAuthenticated,
    this.token = "",
    this.user,
    this.store,
    this.unreadNotification = 0
  });

  AuthState copyWith({
    bool? isAuthenticated,
    String? token,
    UserModel? user,
    StoreModel? store
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      token: token ?? this.token,
      user: user ?? this.user,
      store: store ?? this.store,
      unreadNotification: unreadNotification
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "isAuthenticated": isAuthenticated,
      "token": token,
      "user": user?.toJson(),
      "store": store?.toJson(),
      "unreadNotification": unreadNotification
    };
  }
}

final class AuthLoading extends AuthState {}

final class AuthRegisterLoading extends AuthState {}

final class AuthRequestResetPasswordLoading extends AuthState {}
