import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maps_app/ui/widgets/empty_list_widget.dart';
import 'package:maps_app/ui/widgets/role_chips.dart';
import '../../../../data/models/user.dart';
import '../../../../routing/app_routes.dart';
import '../../../../utils/constants.dart';
import '../../../bloc/authentication/authentication_bloc.dart';
import '../../../bloc/authentication/authentication_event.dart';
import '../../../bloc/internet_connection/internet_connection_bloc.dart';
import '../../../bloc/user_list/user_list_cubit.dart';
import '../../../bloc/user_list/user_list_state.dart';


class UserListScreen extends StatelessWidget{
  const UserListScreen({super.key});

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
        appBar: AppBar(),
        floatingActionButtonLocation: ExpandableFab.location,
        floatingActionButton: ExpandableFab(
          distance: 70.0,
          openButtonBuilder: RotateFloatingActionButtonBuilder(
            child: const Icon(Icons.add),
            fabSize: ExpandableFabSize.regular,
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            shape:  RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          type: ExpandableFabType.up,
          children: [
            _buildFabButton(
              context,
              icon: Icons.directions_car,
              label: 'سائق',
              heroTag: 'add_driver',
              role: UserRole.driver,
            ),
            _buildFabButton(
              context,
              icon: Icons.mosque,
              label: 'إمام',
              heroTag: 'add_imam',
              role: UserRole.imam,
            ),
          ],
        ),
          body: BlocListener<UserListCubit, UserListState>(
              listener: (context, state) {
                if (state.status == UserListStatus.failed) {
                  Constants.showSnackBar(context, Icons.error_outline,
                      state.errorMessage ?? 'حدث خطأ في عملية حفض المعلومات',
                      Colors.redAccent, const Duration(seconds: 5));
                }
                else if(state.status == UserListStatus.success && state.successMessage != null && state.successMessage!.isNotEmpty){
                  Constants.showSnackBar(context, Icons.library_add_check, state.successMessage!, Colors.green, const Duration(seconds:2));
                }else if (state.status == UserListStatus.tokenExpired){
                  context.read<AuthenticationBloc>().add(AdminLogoutRequested());
                  Constants.showSnackBar(context, Icons.error_outline, state.errorMessage!, Colors.redAccent, const Duration(seconds:2));
                }
              },
              child: Column(
                children: [
                  _SearchBar(),
                  FilterChips(
                    chipLabels: Constants.userRoles,
                    initialSelected: Constants.userRoles[0],
                    onSelected: (role) {
                      context.read<UserListCubit>().getAllUsers(getRole(role));
                      context.read<UserListCubit>().clearSearchQuery();
                    },
                  ),
                  Expanded(child: UsersList(role: UserRole.driver,)),
                ],
              ))),
    );
  }
  UserRole getRole(String role) {
    switch (role) {
      case 'السائقين':
        return UserRole.driver;
      case 'الائمة':
        return UserRole.imam;
      case 'المسؤولين':
        return UserRole.admin;
      default:
        return UserRole.driver; // or whatever default you prefer
    }
  }
  Widget _buildFabButton(
      BuildContext context, {
        required IconData icon,
        required String label,
        required String heroTag,
        required UserRole role,
      }) {
    final theme = Theme.of(context);
    return FloatingActionButton.extended(
      onPressed: () {
        context.pushReplacementNamed(AppRoutes.AddUser,extra: {
          'role': role
        });
      },
      backgroundColor: theme.colorScheme.secondary,
      heroTag: heroTag,
      label:  Text(
        'اضافة $label',
        style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onPrimary
        ),
      ),
      icon:  Icon(
        icon,
        color: Colors.white,
      ),
    );
  }
}

class UsersList extends StatefulWidget {
  final UserRole role;

  const UsersList({
    required this.role,
    super.key,
  });

  @override
  State<UsersList> createState() => _UsersListState();
}

class _UsersListState extends State<UsersList> {
  @override
  void initState() {
    context.read<UserListCubit>().getAllUsers(widget.role);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<UserListCubit, UserListState>(
      builder: (context, state) {
        if (state.status == UserListStatus.loading) {
          return SpinKitThreeBounce(
            color: theme.colorScheme.secondary,
            size: 40.0,
          );
        }

        final showFiltered = state.searchQuery.isNotEmpty;
        var users = showFiltered ? state.filteredUsers : state.usersList;
        //final users = List.of(Constants.mockUsers);

        return users.isNotEmpty
            ? ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            return UserItem(user: users[index]);
          },
        )
            : EmptyListWidget();
      },
    );
  }
}

class UserItem extends StatelessWidget {
  final User user;

  const UserItem({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final username = '${user.firstName} ${user.lastName}';
    return Card(
      elevation: 4,
      color: theme.colorScheme.surface,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: () {
          context.pushReplacementNamed(AppRoutes.UserDetails, extra: user);
        },
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: theme.colorScheme.primary,
                child: Text(
                  username.isNotEmpty
                      ? username.substring(0, 1).toUpperCase()
                      : '?',
                  style: const TextStyle(fontSize: 24, color: Colors.white),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username,
                      style:theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.phone, size: 16, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          user.number!,
                          style: theme.textTheme.bodyLarge)
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: theme.colorScheme.primary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<UserListCubit, UserListState>(
        buildWhen: (prevState, currState) {
          return prevState.searchQuery != currState.searchQuery;
        }, builder: (context, state) {

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_searchController.text != state.searchQuery) {
          _searchController.text = state.searchQuery;
          _searchController.selection = TextSelection.fromPosition(
            TextPosition(offset: _searchController.text.length),
          );
        }
      });
      return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: TextField(
            onChanged: (value) {
              context.read<UserListCubit>().searchUser(value);
            },
            cursorColor: theme.colorScheme.primary,
            controller: _searchController,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                ),
              ),
              filled: true,
              fillColor: Colors.white,
              hintText: 'البحث عن مترشح',
              hintStyle: const TextStyle(color: Colors.grey),
              prefixIcon: Icon(Icons.person_search_outlined,
                  color: theme.colorScheme.primary),
              suffixIcon: IconButton(
                  onPressed: () {
                    context
                        .read<UserListCubit>()
                        .clearSearchQuery();
                    _searchController.text = '';
                  },
                  icon: Icon(state.searchQuery.isEmpty ? null : Icons.close,
                      color: theme.colorScheme.primary)),
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.grey[700]!),
              ),
            ),
          ));
    });
  }
}
