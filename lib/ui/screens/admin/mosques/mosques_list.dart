import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:maps_app/ui/widgets/custom_search_bar.dart';
import '../../../../data/models/mosque.dart';
import '../../../../routing/app_routes.dart';
import '../../../../utils/constants.dart';
import '../../../bloc/authentication/authentication_bloc.dart';
import '../../../bloc/authentication/authentication_event.dart';
import '../../../bloc/internet_connection/internet_connection_bloc.dart';
import '../../../bloc/mosque/add_mosque_cubit.dart';
import '../../../bloc/mosque/mosque_list_cubit.dart';
import '../../../bloc/mosque/mosque_list_state.dart';
import '../../../widgets/empty_list_widget.dart';


class MosqueListScreen extends StatelessWidget{
  const MosqueListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocListener<InternetConnectionBloc,InternetState>(
      listener: (context,state){
        if(state == InternetState.offline){
          Constants.showSnackBar(context, Icons.wifi_tethering_off, 'انت غير متصل بالإنترنت', Colors.redAccent, const Duration(seconds: 5));
        }else if(state == InternetState.online){
          Constants.showSnackBar(context, Icons.wifi_tethering, 'انت الان متصل بالانترنت', Colors.green, const Duration(seconds: 3));
        }
      },
      child: Scaffold(
          appBar: AppBar(

          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              context.read<AddMosqueCubit>().initialState();
              context.pushReplacementNamed(AppRoutes.AddMosque);
            },
            backgroundColor: theme.colorScheme.secondary,
            label:  Text(
              'اضافة مسجد',
              style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onPrimary
              ),
            ),
            icon: const Icon(
              Icons.add,
              color: Colors.white,
            ),
          ),
          body: BlocListener<MosqueListCubit, MosqueListState>(
              listener: (context, state) {
                if (state.status == MosqueListStatus.failed) {
                  Constants.showSnackBar(context, Icons.error_outline,
                      state.errorMessage ?? 'حدث خطأ في عملية حفض المعلومات',
                      Colors.redAccent, const Duration(seconds: 5));
                }
                else if (state.status == MosqueListStatus.tokenExpired){
                  context.read<AuthenticationBloc>().add(AdminLogoutRequested());
                  Constants.showSnackBar(context, Icons.error_outline, state.errorMessage!, Colors.redAccent, const Duration(seconds:2));
                }
              },
              child: Column(
                children: [
                  _SearchBar(),
                  Expanded(child: MosquesList()),
                ],
              ))),
    );
  }
}

class MosquesList extends StatefulWidget {

  const MosquesList({
    super.key,
  });

  @override
  State<MosquesList> createState() => _MosquesListState();
}

class _MosquesListState extends State<MosquesList> {
  @override
  void initState() {
    context.read<MosqueListCubit>().getAllMosques();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<MosqueListCubit, MosqueListState>(
      builder: (context, state) {
        if (state.status == MosqueListStatus.loading) {
          return SpinKitThreeBounce(
            color: theme.colorScheme.secondary,
            size: 40.0,
          );
        }

        final showFiltered = state.searchQuery.isNotEmpty;
        var mosques = showFiltered ? state.filteredList : state.mosquesList;
        //final mosques = Constants.mockMosques;

        return mosques.isNotEmpty
            ? ListView.builder(
          itemCount: mosques.length,
          itemBuilder: (context, index) {
            return MosqueItem(mosque: mosques[index],);
          },
        )
            : EmptyListWidget(emptyMessage:'لا يوجد مساجد حاليا');
      },
    );
  }
}

class MosqueItem extends StatelessWidget {
  final Mosque mosque;

  const MosqueItem({
    Key? key,
    required this.mosque,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final bool hasLocation = mosque.lat != null && mosque.ling != null;
    final bool isApproved = mosque.isApproved == true;

    final bool showLocationMissing = !hasLocation;
    final bool showNotApproved = hasLocation && !isApproved;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          // handle tap if needed
          context.read<AddMosqueCubit>().getMosqueDetails(mosque.id!);
          context.pushReplacementNamed(AppRoutes.AddMosque, extra: mosque.id!);
        },
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: theme.colorScheme.primary,
                child: Icon(
                  Icons.mosque_outlined,
                  color: theme.colorScheme.onPrimary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.location_city, size: 18, color: Colors.grey),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            mosque.name,
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    if (mosque.address != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.place, size: 18, color: Colors.grey),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              mosque.address!,
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (mosque.imam != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.person, size: 18, color: Colors.grey),
                          const SizedBox(width: 6),
                          Text(
                            'الإمام: ${mosque.imam!.firstName} ${mosque.imam!.lastName}',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                    if (showLocationMissing || showNotApproved) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            size: 18,
                            color: showLocationMissing ? Colors.red : Colors.orange,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              showLocationMissing
                                  ? 'لم يتم تحديد موقع المسجد'
                                  : 'موقع المسجد غير مُعتمد',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: showLocationMissing ? Colors.red : Colors.orange,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Align(
                alignment: Alignment.center,
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: theme.colorScheme.primary,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MosqueListCubit, MosqueListState>(
      buildWhen: (prev, curr) => prev.searchQuery != curr.searchQuery,
      builder: (context, state) {
        return CustomSearchBar(
          searchText: state.searchQuery,
          onChanged: (value) => context.read<MosqueListCubit>().searchMosque(value),
          onClear: () => context.read<MosqueListCubit>().searchMosque(''),
          hintText: 'البحث عن مسجد',
          prefixIcon: Icons.mosque_outlined,
        );
      },
    );
  }
}
