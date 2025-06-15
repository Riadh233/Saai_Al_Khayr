import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:maps_app/data/api/database_service.dart';
import 'package:maps_app/main.dart';
import 'package:maps_app/ui/bloc/user_list/user_list_state.dart';

import '../../../data/models/user.dart';

class UserListCubit extends Cubit<UserListState>{
  UserListCubit(this._databaseService) : super(UserListState());
  final DatabaseService _databaseService;
  void addUser(User user) async{
    try{
      emit(state.copyWith(status: UserListStatus.loading));
      logger.log(Logger.level, state.status);
      await _databaseService.addUser(user);
      emit(state.copyWith(status: UserListStatus.success));
    }on ApiException catch(e){
      emit(state.copyWith(status: UserListStatus.failed, errorMessage: e.message));
    }on TokenException catch(e){
      //emit token expired
      emit(state.copyWith(status: UserListStatus.tokenExpired, errorMessage: e.message));
    }
  }
  void updateUser(User currUser,User newUser) async{
    try{
      emit(state.copyWith(status: UserListStatus.loading));
      await _databaseService.updateUser(_getUpdatedFields(currUser, newUser), currUser.id!);
      emit(state.copyWith(status: UserListStatus.success));
    }on ApiException catch(e){
      emit(state.copyWith(status: UserListStatus.failed,errorMessage: e.message));
    }on TokenException catch(e){
      //emit token expired
      emit(state.copyWith(status: UserListStatus.tokenExpired, errorMessage: e.message));
    }
  }
  void deleteUser(User user) async{
    try{
      emit(state.copyWith(status: UserListStatus.loading));
      await _databaseService.deleteUser(user.id!);
      emit(state.copyWith(status: UserListStatus.success));
    }on ApiException catch(e){
      emit(state.copyWith(status: UserListStatus.failed, errorMessage: e.message));
    }on TokenException catch(e){
      //emit token expired
      emit(state.copyWith(status: UserListStatus.tokenExpired, errorMessage: e.message));
    }
  }
  void getAllUsers(UserRole role) async {
    try{
      emit(state.copyWith(status: UserListStatus.loading));
      final usersList = await _databaseService.getAllUsers(role);
      emit(state.copyWith(usersList: usersList,status: UserListStatus.success));
    }on ApiException catch(e){
      emit(state.copyWith(status: UserListStatus.failed, errorMessage: e.message));
    }on TokenException catch(e){
      //emit token expired
      logger.log(Level.error, 'token expired');
      emit(state.copyWith(status: UserListStatus.tokenExpired, errorMessage: e.message));
    }
  }

  void searchUser(String query){
    final filteredUsers = state.usersList
        .where((user) =>
        user.firstName.toLowerCase().contains(query.toLowerCase()) || user.lastName.toLowerCase().contains(query.toLowerCase()))
        .toList();
    emit(state.copyWith(
        filteredUsers: filteredUsers,
        searchQuery: query,
        successMessage: ''
    ));
  }
  void clearSearchQuery(){
    emit(state.copyWith(searchQuery: ''));
  }

  Map<String, dynamic> _getUpdatedFields(User oldUser, User updatedUser) {
    final Map<String, dynamic> updatedFields = {};

    if (oldUser.firstName != updatedUser.firstName) {
      updatedFields['name'] = updatedUser.firstName;
    }
    if (oldUser.lastName != updatedUser.lastName) {
      updatedFields['famillyName'] = updatedUser.lastName;
    }
    if (oldUser.password != updatedUser.password) {
      updatedFields['email'] = updatedUser.password;
    }
    if (oldUser.number != updatedUser.number) {
      updatedFields['number'] = updatedUser.number;
    }
    if (oldUser.carNumber != updatedUser.carNumber) {
      updatedFields['carNumber'] = updatedUser.carNumber;
    }
    if (oldUser.status != updatedUser.status) {
      updatedFields['role'] = updatedUser.status.name; // or updatedUser.status.toString() if needed
    }

    return updatedFields;
  }

}