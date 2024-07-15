part of 'app_bloc.dart';

final class AppState {

  AppState({
    this.language = "id",
    this.isDarkMode = false
  });

  String language;
  bool isDarkMode;
}
