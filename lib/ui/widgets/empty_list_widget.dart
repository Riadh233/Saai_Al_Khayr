import 'package:flutter/material.dart';

class EmptyListWidget extends StatelessWidget{
  final String? emptyMessage;

  const EmptyListWidget({super.key, this.emptyMessage});
  @override
  Widget build(BuildContext context) {

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/empty_image.png', height: 100, width: 100),
          Text(
            emptyMessage ?? 'لا يوجد مستخدمين حاليا',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}