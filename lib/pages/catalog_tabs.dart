import 'package:flutter/material.dart';
import 'package:navigator_20/navigation/index.dart';

class TabA extends StatelessWidget {
  const TabA({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.cyan,
      child: const Center(child: Text('Tab A')),
    );
  }
}

class TabB extends StatelessWidget {
  const TabB({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.orange,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Tab B'),
            MaterialButton(
              color: Colors.cyan,
              onPressed: () async {
                final result =
                    await Navigation.of(context).navigateForResult<Object>(
                  const PlainPageConfiguration(pageName: PageName.details),
                  globalNavigation: true,
                );
                _showSnackBarWithResult(context ,result);
              },
              child: const Text('Open details from root'),
            ),
          ],
        ),
      ),
    );
  }
}

class TabC extends StatelessWidget {
  const TabC({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.purple,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Tab C'),
            MaterialButton(
              color: Colors.cyan,
              onPressed: () async {
                final result =
                    await Navigation.of(context).navigateForResult<Object>(
                  const PlainPageConfiguration(
                    pageName: PageName.details,
                  ),
                );
                _showSnackBarWithResult(context ,result);
              },
              child: const Text('Open details'),
            ),
            MaterialButton(
              color: Colors.cyan,
              onPressed: () {
                Navigation.of(context).navigate(
                  const ModalPageConfiguration(pageName: PageName.dialog),
                  globalNavigation: true,
                );
              },
              child: const Text('Open dialog'),
            ),
          ],
        ),
      ),
    );
  }
}

void _showSnackBarWithResult(BuildContext context, Object? result) {
  final resultText = result?.toString() ?? 'No result';
  ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(resultText)));
}
