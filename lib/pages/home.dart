import 'package:flutter/material.dart';
import 'package:navigator_20/navigation/index.dart';

class HomePage extends StatelessWidget {
  const HomePage();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MaterialButton(
              color: Colors.cyan,
              onPressed: () {
                Navigation.of(context).navigate(const PlainPageConfiguration(pageName: PageName.details));
              },
              child: const Text('Open Details'),
            ),
          ],
        ),
      ),
    );
  }
}
