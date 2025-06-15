import 'package:equatable/equatable.dart';

import '../../../data/models/user.dart';

enum UserListStatus {
  loading,
  success,
  failed,
  tokenExpired
}

class UserListState extends Equatable {
  final List<User> usersList;
  final List<User> filteredUsers;
  final String searchQuery;
  final UserListStatus status;
  final String? errorMessage;
  final String? successMessage;

  const UserListState({
    this.usersList = const <User>[],
    this.filteredUsers = const <User>[],
    this.searchQuery = '',
    this.status = UserListStatus.loading,
    this.errorMessage,
    this.successMessage,
  });

  UserListState copyWith(
      {List<User>? usersList,
        List<User>? filteredUsers,
        String? searchQuery,
        UserListStatus? status,
        String? errorMessage,
        String? successMessage}) {
    return UserListState(
      usersList: usersList ?? this.usersList,
      filteredUsers: filteredUsers ?? this.filteredUsers,
      searchQuery: searchQuery ?? this.searchQuery,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
    );
  }

  @override
  List<Object?> get props => [
    usersList,
    status,
    filteredUsers,
    searchQuery,
    errorMessage,
    successMessage
  ];
}
