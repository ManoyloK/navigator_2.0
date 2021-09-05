import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:navigator_20/navigation/index.dart';

class RootPage extends StatefulWidget {
  const RootPage({Key? key}) : super(key: key);

  @override
  _RootPageState createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  int _index = 0;

  void _updatePage(int index) {
    if (index != _index) {
      setState(() {
        _index = index;
        PageName page;
        if (_index == 0) {
          page = PageName.home;
        } else {
          page = PageName.catalog;
        }
        Navigation.of(context).navigate(PlainPageConfiguration(pageName: page));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            label: 'Home',
            icon: Icon(Icons.home),
          ),
          BottomNavigationBarItem(
            label: 'Catalog',
            icon: Icon(Icons.apps),
          ),
        ],
        onTap: _updatePage,
        currentIndex: _index,
      ),
      body: MultiNavigationHostView(
        navigation: Navigation.of(context),
        roots: const [PageName.home, PageName.catalog],
        activeViewIndexChanged: _updatePage,
        viewBuilder: (BuildContext context, List<Widget> children) {
          return Stack(
            children: children,
          );
        },
        oneLevelNavigation: false,
      ),
    );
  }
}
