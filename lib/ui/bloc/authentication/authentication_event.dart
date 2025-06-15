
import '../../../data/models/user.dart';

sealed class AuthenticationEvent {
  const AuthenticationEvent();
}

final class AdminLogoutRequested extends AuthenticationEvent {
  const AdminLogoutRequested();
}

final class AdminLoginRequested extends AuthenticationEvent {
  final UserRole role;
  const AdminLoginRequested(this.role);
}

final class AppStarted extends AuthenticationEvent {
  const AppStarted();
}
