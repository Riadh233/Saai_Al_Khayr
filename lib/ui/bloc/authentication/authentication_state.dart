import 'package:equatable/equatable.dart';

import '../../../data/models/user.dart';


enum AuthenticationStatus{
  authenticated,
  unauthenticated,
  unknown
}

final class AuthenticationState extends Equatable{
  const AuthenticationState._({
    required this.status,
    this.user = User.empty,
    this.userRole
  });
  const AuthenticationState.authenticated({UserRole? userRole}) : this._(status: AuthenticationStatus.authenticated,userRole: userRole);
  const AuthenticationState.unauthenticated() : this._(status: AuthenticationStatus.unauthenticated,user: User.empty);
  const AuthenticationState.unknown() : this._(status: AuthenticationStatus.unknown,user: User.empty);

  final User user;
  final UserRole? userRole;
  final AuthenticationStatus status;

  @override
  List<Object?> get props => [user,userRole,status];
}