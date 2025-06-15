import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import '../../widgets/custom_search_bar.dart';
import 'mission/admin_missions_screen.dart';

class MoneyCollectionScreen extends StatefulWidget {
  @override
  State<MoneyCollectionScreen> createState() => _MoneyCollectionScreenState();
}

class _MoneyCollectionScreenState extends State<MoneyCollectionScreen> with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  bool _showFab = true;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      final direction = _scrollController.position.userScrollDirection;

      if (direction == ScrollDirection.reverse && _showFab) {
        setState(() => _showFab = false);
      } else if (direction == ScrollDirection.forward && !_showFab) {
        setState(() => _showFab = true);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(),
      floatingActionButton: AnimatedSlide(
        duration: const Duration(milliseconds: 300),
        offset: _showFab ? Offset.zero : const Offset(0, 2),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: _showFab ? 1.0 : 0.0,
          child: FloatingActionButton.extended(
            onPressed: () {
              showDateRangeDialog(context, (_,_){});
              //_showTotalCollectedBottomSheet(context,42000.00);
            },
            backgroundColor: theme.colorScheme.secondary,
            label: Text(
              'حساب مجموع التبرعات',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onPrimary,
              ),
            ),
            icon: const Icon(Icons.receipt_long_outlined, color: Colors.white),
          ),
        ),
      ),
      body: Column(
        children: [
          _SearchBar(),
          DaysAgoFilterChips(
            presetDays: const [0, 7, 30],
            initialSelected: 0,
            onSelected: (days) {},
          ),
          const SizedBox(height: 15),
          Expanded(child: _MissionsList(scrollController: _scrollController)),
        ],
      ),
    );
  }

  void _showTotalCollectedBottomSheet(BuildContext context, double totalAmount) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      backgroundColor: theme.colorScheme.background,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.drag_handle, color: Colors.grey.shade400),
              const SizedBox(height: 15),
              Text(
                'مجموع التبرعات',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                  //  Icon(Icons.attach_money, color: theme.colorScheme.primary, size: 30),
                    const SizedBox(width: 10),
                    Text(
                      '${totalAmount.toStringAsFixed(0)} دج',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'تم حساب مجموع التبرعات حسب الفترة المحددة.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
  Future<void> showDateRangeDialog(
      BuildContext context,
      Function(String fromDate, String toDate) onSubmit,
      ) async {
    final fromController = TextEditingController();
    final toController = TextEditingController();

    DateTime? fromDate;
    DateTime? toDate;

    Future<void> _pickDate(
        BuildContext context,
        TextEditingController controller,
        Function(DateTime) onPicked,
        ) async {
      final picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2023),
        lastDate: DateTime.now(),
        helpText: 'اختيار التاريخ',
        locale: const Locale('ar', 'DZ'),
      );
      if (picked != null) {
        controller.text =
        "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
        onPicked(picked);
      }
    }

    return showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          titlePadding: EdgeInsets.fromLTRB(24, 24, 24, 8),
          contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          title: Row(
            children: [
              Icon(Icons.attach_money_rounded, color: Colors.green[700]),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  "تقرير جمع التبرعات",
                  style: TextStyle(fontFamily: "Poppins", fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "أدخل الفترة الزمنية لعرض المبالغ المجموعة خلال المهام المكتملة.",
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              buildStyledDateInput(
                context: context,
                label: "من تاريخ",
                icon: Icons.calendar_today,
                controller: fromController,
                onTap: () => _pickDate(context, fromController, (picked) => fromDate = picked),
              ),
              SizedBox(height: 12),
              buildStyledDateInput(
                context: context,
                label: "إلى تاريخ",
                icon: Icons.calendar_today,
                controller: toController,
                onTap: () => _pickDate(context, toController, (picked) => toDate = picked),
              ),
            ],
          ),
          actionsPadding: EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            TextButton(
              child: Text("إلغاء"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton.icon(
              icon: Icon(Icons.bar_chart),
              label: Text("عرض التقرير", style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white
              ),),
              onPressed: () {
                if (fromController.text.isNotEmpty && toController.text.isNotEmpty) {
                  onSubmit(fromController.text, toController.text);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ],
        );
      },
    );
  }
  Widget buildStyledDateInput({
    required BuildContext context,
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return TextField(
      controller: controller,
      readOnly: true,
      onTap: onTap,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        hintText: label,
        prefixIcon: Icon(icon, color: theme.colorScheme.primary),
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.grey[200],
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.blueGrey[700]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
      ),
    );
  }

}

class _MissionsList extends StatelessWidget{
  final ScrollController scrollController;

  const _MissionsList({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    //final missions = Constants.mockCompletedMissions;
    final missions = [];
    return ListView.builder(
      controller: scrollController,
      itemCount: missions.length,
      itemBuilder: (context, index) {
        final mission = missions[index];
        return _missionItem(driverName: mission.driverName,
          driverPhone: mission.driverPhone,
          mosqueName: mission.mosqueName,
          amount: mission.amount,
          collectionDate: mission.collectionDate,);
      },
    );
  }
  Widget _missionItem({
    required String driverName,
    required String driverPhone,
    required String mosqueName,
    required double amount,
    required DateTime collectionDate,
  }) {
    final dateFormatted = DateFormat.yMMMMd().format(collectionDate);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mosque name and amount
            Row(
              children: [
                const Icon(Icons.mosque, color: Color(0xFF4EC7A6)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    mosqueName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '${amount.toStringAsFixed(0)} د.ج',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Driver info
            Row(
              children: [
                const Icon(Icons.person, size: 20, color: Colors.grey),
                const SizedBox(width: 6),
                Text(driverName),
                const Spacer(),
                const Icon(Icons.phone, size: 20, color: Colors.grey),
                const SizedBox(width: 6),
                Text(driverPhone),
              ],
            ),

            const SizedBox(height: 12),

            // Date
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  dateFormatted,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

}
class _SearchBar extends StatelessWidget {
@override
Widget build(BuildContext context) {
  return CustomSearchBar(
    searchText: '',
    onChanged: (value) => (){},
    onClear: () => {},
    hintText: 'البحث عن مهمة',
    prefixIcon: Icons.mosque_outlined,
  );
}
}