import 'package:flutter/material.dart';
import 'package:navigator_20/navigation/index.dart';
import 'package:navigator_20/navigation/page_configuration.dart';

class Details extends StatefulWidget {
  const Details({
    Key? key,
  }) : super(key: key);

  @override
  _DetailsState createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  Object? result;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Builder(
          builder: (BuildContext context) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (result != null) Text('Result:$result'),
                MaterialButton(
                  color: Colors.cyan,
                  onPressed: () async {
                    result = await Navigation.of(context).navigateForResult(
                      const PlainPageConfiguration(pageName: PageName.details),
                      globalNavigation: true,
                    );

                    setState(() {});
                  },
                  child: const Text('Open details from root'),
                ),
                MaterialButton(
                  color: Colors.cyan,
                  onPressed: () {
                    Navigation.of(context).pop(result: 'from details page');
                  },
                  child: const Text('back'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
