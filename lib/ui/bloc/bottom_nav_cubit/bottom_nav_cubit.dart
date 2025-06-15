import 'package:flutter_bloc/flutter_bloc.dart';

import 'bottom_nav_state.dart';

class BottomNavCubit extends Cubit<BottomNavState>{
  BottomNavCubit() : super(const BottomNavState(selectedTab: 0));

  void selectedTabChanged(int index){
    emit(BottomNavState(selectedTab: index));
  }
}