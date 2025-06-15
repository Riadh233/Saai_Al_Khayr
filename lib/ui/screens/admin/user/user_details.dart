
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../data/models/user.dart';
import '../../../../routing/app_routes.dart';
import '../../../bloc/user_list/user_list_cubit.dart';
import '../../../bloc/user_list/user_list_state.dart';


class UserDetailsScreen extends StatelessWidget {
  const UserDetailsScreen({super.key, required this.user});

  final User user;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        leading: IconButton(
          icon: Icon(Icons.arrow_back), // Customize the back button icon
          onPressed: () {
            // Handle the back button action
            context.pushReplacementNamed(AppRoutes.Home);
            // Default back behavior
          },
        ),
        title: Text('تفاصيل المستخدم',style: TextStyle(color: theme.colorScheme.onPrimary),),
        elevation: 2,
        actions: [
          IconButton(
              onPressed: () {
                context.pushNamed(AppRoutes.AddUser, extra: {
                  'role':user.status,
                  'user' : user
                });
              },
              icon: Icon(
                Icons.edit_note_rounded,
                color: theme.colorScheme.onPrimary,
              )),
          IconButton(
              onPressed: () {
                //deletion dialogue
                _showDeleteUserAlert(user, context);
              },
              icon: Icon(
                Icons.delete_forever,
                color: theme.colorScheme.onPrimary,
              )),
        ],

      ),
      body: _UserDetailsPage(currentUser: user),
    );
  }

  void _showDeleteUserAlert(User user, BuildContext userContext) {
    final username = '${user.firstName} ${user.lastName}';
    final theme = Theme.of(userContext);
    showDialog(
      context: userContext, // Use the context from the outer scope
      builder: (BuildContext dialogContext) {
        // Renamed to avoid confusion with outer context
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0), // Rounded corners
          ),
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.redAccent), // Warning icon
              SizedBox(width: 8),
              Text(
                'تأكيد الحذف',
                style: theme.textTheme.titleLarge)
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min, // To wrap content
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ستقوم بحذف المستخدم $username. هل تريد المتابعة ؟ ',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
            ],
          ),
          actionsPadding:
          const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Use dialogContext here
              },
              child: const Text(
                'إلغاء',
                style:
                TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                userContext
                    .read<UserListCubit>().deleteUser(user);

                userContext.pushReplacementNamed(AppRoutes.Home);
                dialogContext.pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0), // Rounded button
                ),
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              icon: const Icon(Icons.delete, color: Colors.white),
              label: const Text(
                'حذف',
                style:
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _UserDetailsPage extends StatelessWidget {
  final User currentUser;

  const _UserDetailsPage(
      {super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<UserListCubit, UserListState>(
        builder: (context, state) {
          final username = '${currentUser.firstName} ${currentUser.lastName}';
          final userExists = state.usersList.any((element){
            final e_name = '${element.firstName} ${element.lastName}';
            return e_name == username;
          });
          final User user = userExists ? state.usersList.firstWhere((element){
            final e_name = '${element.firstName} ${element.lastName}';
            return e_name == username;
          }) : User.empty;

          return Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          const Divider(thickness: 1),

                          // Full Name
                          ListTile(
                            leading: const Icon(Icons.person, color: Colors.blueAccent),
                            title: const Text('الاسم الكامل'),
                            subtitle: Text(
                              username,
                              style: theme.textTheme.titleMedium,
                            ),
                          ),
                          const Divider(thickness: 1),

                          if(user.status != UserRole.imam)...[
                            ListTile(
                              leading: const Icon(Icons.car_crash_outlined, color: Colors.blueAccent),
                              title: const Text('رقم لوحة السيارة'),
                              subtitle: Text(
                                user.carNumber!,
                                style: theme.textTheme.titleMedium,
                              ),
                            ),
                            const Divider(thickness: 1),
                          ],

                          // Phone Number
                          ListTile(
                            leading: const Icon(Icons.phone, color: Colors.greenAccent),
                            title: const Text('رقم الهاتف'),
                            subtitle: Text(
                              user.number!,
                              style: theme.textTheme.titleMedium,
                            ),
                          ),
                          const Divider(thickness: 1),
                          // Password
                          ListTile(
                            leading: const Icon(Icons.lock, color: Colors.redAccent),
                            title: const Text('كلمة المرور'),
                            subtitle: Text(
                              user.password,
                              style: theme.textTheme.titleMedium,
                            ),
                          ),
                          const Divider(thickness: 1,),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                )
              ]);
        });
  }
}
