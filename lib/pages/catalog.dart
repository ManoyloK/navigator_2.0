import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:navigator_20/navigation/index.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({
    this.tabIndex,
    Key? key,
  }) : super(key: key);
  final int? tabIndex;

  @override
  _CatalogPageState createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage>
    with SingleTickerProviderStateMixin {

    final _tabsNames = <PageName>[
    PageName.tabA,
    PageName.tabB,
    PageName.tabC,
  ];
  late TabController _tabController;
  Object? result;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      vsync: this,
      length: 3,
      initialIndex: widget.tabIndex ?? 0,
    );
    _tabController.addListener(() {
      _openTab(_tabController.index);
    });
  }

  @override
  void didUpdateWidget(covariant CatalogPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tabIndex != null) {
      result = null;
      _tabController.animateTo(widget.tabIndex!);
    }
  }

  void _openTab(int index) {
    Navigation.of(context).navigate(PlainPageConfiguration(
      pageName: PageName.catalog,
      settings: index,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catalog'),
        elevation: 0.0,
      ),
      backgroundColor: Colors.blue[500],
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: TabBar(
                onTap: (index) {
                  result = null;
                  _openTab(index);
                },
                labelPadding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 0.0),
                indicator: const BoxDecoration(),
                controller: _tabController,
                tabs: [
                  Container(
                    color: Colors.teal,
                    height: kToolbarHeight,
                    alignment: Alignment.center,
                    child: const Text(
                      'A',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(
                    color: Colors.teal,
                    height: kToolbarHeight,
                    alignment: Alignment.center,
                    child: const Text(
                      'B',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(
                    color: Colors.teal,
                    height: kToolbarHeight,
                    alignment: Alignment.center,
                    child: const Text(
                      'C',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            )
          ];
        },
        body: MultiNavigationHostView(
          navigation: Navigation.of(context),
          activeRootViewChanged: (index) =>
              SchedulerBinding.instance!.addPostFrameCallback((_) {
            setState(() {
              _tabController.animateTo(index);
            });
          }),
          oneLevelNavigation: true,
          viewBuilder: (context, children) {
            return TabBarView(
              controller: _tabController,
              children: children,
            );
          },
          roots: _tabsNames,
        ),
      ),
    );
  }
}
