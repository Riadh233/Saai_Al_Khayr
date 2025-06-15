import 'package:equatable/equatable.dart';
import 'package:maps_app/data/models/mosque.dart';

enum MosqueListStatus {loading, success, failed, tokenExpired}

class MosqueListState extends Equatable{
  final List<Mosque> mosquesList;
  final List<Mosque> filteredList;
  final Mosque? selectedMosque;
  final MosqueListStatus status;
  final String searchQuery;
  final String? errorMessage;

  const MosqueListState({
    this.mosquesList = const <Mosque>[],
    this.filteredList = const <Mosque>[],
    this.searchQuery = '',
    this.status = MosqueListStatus.loading,
    this.selectedMosque = Mosque.empty,
    this.errorMessage,
  });

  MosqueListState copyWith({
    List<Mosque>? mosquesList,
    List<Mosque>? filteredList,
    MosqueListStatus? status,
    String? searchQuery,
    Mosque? selectedMosque,
    String? errorMessage,
  }) {
    return MosqueListState(
      mosquesList: mosquesList ?? this.mosquesList,
      filteredList: filteredList ?? this.filteredList,
      status: status ?? this.status,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedMosque: selectedMosque ?? this.selectedMosque,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    mosquesList,
    filteredList,
    status,
    searchQuery,
    errorMessage,
  ];

}