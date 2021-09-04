import 'package:flutter/material.dart';
import 'package:navigator_20/navigation/index.dart';

class AppDialog extends StatelessWidget {
  const AppDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Dialog'),
      content: const Text('Return result?'),
      actions: [
        MaterialButton(
          child: const Text('Yes'),
          onPressed: () {
            Navigation.of(context).pop(result: true);
          },
        ),
        MaterialButton(
          child: const Text('No'),
          onPressed: () {
            Navigation.of(context).pop();
          },
        )
      ],
    );
  }
}
