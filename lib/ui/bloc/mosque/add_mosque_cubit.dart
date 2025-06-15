import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:logger/logger.dart';
import 'package:maps_app/data/api/database_service.dart';
import 'package:maps_app/data/models/user.dart';
import 'package:maps_app/main.dart';
import 'package:maps_app/utils/formz/latitude.dart';
import 'package:maps_app/utils/formz/longitude.dart';
import 'package:maps_app/utils/formz/username.dart';

import '../../../data/models/mosque.dart';
import '../../../utils/formz/address.dart';
import 'add_mosque_state.dart';

class AddMosqueCubit extends Cubit<AddMosqueState> {
  AddMosqueCubit(this._databaseService) : super(AddMosqueState());

  final DatabaseService _databaseService;

  void initialState() {
    emit(AddMosqueState());
  }

  void mosqueNameChanged(String value) {
    final mosqueName = Username.dirty(value);
    emit(
      state.copyWith(
        name: mosqueName,
        isValid: _validateForm(
          name: mosqueName,
          latitude: state.latitude,
          longitude: state.longitude,
          address: state.address,
        ),
      ),
    );
  }

  void addressChanged(String value) {
    final address = Address.dirty(value);
    emit(
      state.copyWith(
        address: address,
        isValid: _validateForm(
          name: state.name,
          latitude: state.latitude,
          longitude: state.longitude,
          address: address,
        ),
      ),
    );
  }

  void latitudeChanged(String value) {
    final latitude = Latitude.dirty(value);
    final isApproved = latitude.isValid && state.longitude.isValid;
    emit(
      state.copyWith(
        latitude: latitude,
        isApproved: isApproved,
        isValid: _validateForm(
          name: state.name,
          latitude: latitude,
          longitude: state.longitude,
          address: state.address,
        ),
      ),
    );
  }

  void longitudeChanged(String value) {
    final longitude = Longitude.dirty(value);
    final isApproved = state.latitude.isValid && longitude.isValid;
    emit(
      state.copyWith(
        longitude: longitude,
        isApproved: isApproved,
        isValid: _validateForm(
          name: state.name,
          latitude: state.latitude,
          longitude: longitude,
          address: state.address,
        ),
      ),
    );
  }

  void imamChanged(User imam) {
    final hasCoordinates = imam.lat != null && imam.lng != null;

    final updatedLatitude = hasCoordinates
        ? Latitude.dirty(imam.lat.toString())
        : state.latitude;
    final updatedLongitude = hasCoordinates
        ? Longitude.dirty(imam.lng.toString())
        : state.longitude;

    emit(
      state.copyWith(
        imam: imam,
        latitude: updatedLatitude,
        longitude: updatedLongitude,
        isApproved: hasCoordinates ? true : state.isApproved,
        isValid: _validateForm(
          name: state.name,
          latitude: updatedLatitude,
          longitude: updatedLongitude,
          address: state.address,
        ),
      ),
    );
  }

  void approveLocation() {
    emit(state.copyWith(isApproved: true));
  }
  bool _shouldInclude(FormzInput input) {
    return input.value.toString().trim().isNotEmpty;
  }

  bool _validateForm({
    required Username name,
    required Latitude latitude,
    required Longitude longitude,
    required Address address,
  }) {
    final inputs = <FormzInput>[
      name,
      if (_shouldInclude(latitude)) latitude,
      if (_shouldInclude(longitude)) longitude,
      if (_shouldInclude(address)) address,
    ];
    return Formz.validate(inputs);
  }

  void addMosque(Mosque mosque) async {
    try {
      emit(state.copyWith(loadStatus: AddMosqueStatus.loading));
      await _databaseService.addMosque(mosque);
      emit(state.copyWith(loadStatus: AddMosqueStatus.success));
    } on ApiException catch (e) {
      emit(
        state.copyWith(
          loadStatus: AddMosqueStatus.failed,
          errorMessage: e.message,
        ),
      );
    } on TokenException catch (e) {
      //emit token expired
      emit(
        state.copyWith(
          loadStatus: AddMosqueStatus.tokenExpired,
          errorMessage: e.message,
        ),
      );
    }
  }

  void updateMosque(Mosque newMosque) async {
    try {
      emit(state.copyWith(loadStatus: AddMosqueStatus.loading));
      await _databaseService.updateMosque(newMosque);
      emit(state.copyWith(loadStatus: AddMosqueStatus.success));
    } on ApiException catch (e) {
      emit(
        state.copyWith(
          loadStatus: AddMosqueStatus.failed,
          errorMessage: e.message,
        ),
      );
    } on TokenException catch (e) {
      //emit token expired
      emit(
        state.copyWith(
          loadStatus: AddMosqueStatus.tokenExpired,
          errorMessage: e.message,
        ),
      );
    }
  }

  void deleteMosque(int mosqueId) async {
    try {
      logger.log(Logger.level, '${mosqueId}');
      emit(state.copyWith(loadStatus: AddMosqueStatus.loading));
      await _databaseService.deleteMosque(mosqueId);
      emit(state.copyWith(loadStatus: AddMosqueStatus.success));
    } on ApiException catch (e) {
      logger.log(Logger.level, 'delete mosque failure ${e.message}');
      emit(
        state.copyWith(
          loadStatus: AddMosqueStatus.failed,
          errorMessage: e.message,
        ),
      );
    } on TokenException catch (e) {
      //emit token expired
      emit(
        state.copyWith(
          loadStatus: AddMosqueStatus.tokenExpired,
          errorMessage: e.message,
        ),
      );
    }
  }

  Future<void> getMosqueDetails(int id) async {
    try {
      emit(state.copyWith(loadStatus: AddMosqueStatus.loading));
      final selectedMosque = await _databaseService.getMosqueDetails(id);
      logger.log(Logger.level, 'mosque is approved : ${selectedMosque.isApproved}');
      emit(
        state.copyWith(
          name: Username.dirty(selectedMosque.name),
          address: Address.dirty(selectedMosque.address ?? ''),
          imam: selectedMosque.imam,
          isApproved: selectedMosque.isApproved,
          latitude: Latitude.dirty(selectedMosque.lat ?? ''),
          longitude: Longitude.dirty(selectedMosque.ling ?? ''),
          loadStatus: AddMosqueStatus.detailsLoaded,
        ),
      );
    } on ApiException catch (e) {
      emit(
        state.copyWith(
          loadStatus: AddMosqueStatus.failed,
          errorMessage: e.message,
        ),
      );
    } on TokenException catch (e) {
      //emit token expired
      emit(
        state.copyWith(
          loadStatus: AddMosqueStatus.tokenExpired,
          errorMessage: e.message,
        ),
      );
    }
  }

  Future<void> getImamsWithoutCoordinates() async {
    try {
      emit(state.copyWith(loadStatus: AddMosqueStatus.loading));
      final list = await _databaseService.getImamsWithoutCoordinates();
      emit(
        state.copyWith(
          loadStatus: AddMosqueStatus.imamsLoaded,
          imamsList: list,
        ),
      );
    } on ApiException catch (e) {
      emit(
        state.copyWith(
          loadStatus: AddMosqueStatus.failed,
          errorMessage: e.message,
        ),
      );
    } on TokenException catch (e) {
      //emit token expired
      emit(
        state.copyWith(
          loadStatus: AddMosqueStatus.tokenExpired,
          errorMessage: e.message,
        ),
      );
    }
  }

  Map<String, dynamic> _getUpdatedFields(
    Mosque oldMosque,
    Mosque updatedMosque,
  ) {
    final Map<String, dynamic> updatedFields = {};

    if (oldMosque.name != updatedMosque.name) {
      updatedFields['name'] = updatedMosque.name;
    }
    if (oldMosque.address != updatedMosque.address) {
      updatedFields['address'] = updatedMosque.address;
    }
    if (oldMosque.lat != updatedMosque.lat) {
      updatedFields['latitude'] = updatedMosque.lat;
    }
    if (oldMosque.ling != updatedMosque.ling) {
      updatedFields['longitude'] = updatedMosque.ling;
    }
    if (oldMosque.imam != updatedMosque.imam) {
      updatedFields['imam_id'] = updatedMosque.imam!.id!;
    }
    return updatedFields;
  }

  @override
  void onChange(Change<AddMosqueState> change) {
    // TODO: implement onChange
    logger.log(
      Logger.level,
      'curr state :is approved: ${change.currentState.isApproved} is valid:${change.currentState.isValid}, next state is approved: ${change.nextState.isApproved} isvalid : ${change.nextState.isValid}',
    );
    super.onChange(change);
  }
}
