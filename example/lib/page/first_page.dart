import 'package:flutter/material.dart';
import 'package:flutter_annotation_router/flutter_annotation_router.dart';
import '../route/router.navigate.dart';
import 'second_page.dart';

@RoutePage('/first', alias: 'First')
class FirstPage extends StatefulWidget {
  @RouteValue()
  final String text;
  @RouteValue(defaultValue: true)
  final bool? isModal;

  @RouteValue(validate: r'\d+')
  final int age;

  const FirstPage(
      {Key? key, required this.text, required this.age, this.isModal})
      : super(key: key);

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.text)),
      body: Column(
        children: [
          TextButton(
            onPressed: () => context.toSecondPage(),
            child: const Text('Go Second Page'),
          ),
          TextButton(
            onPressed: _showPopup,
            child: const Text('Go Popup Page'),
          ),
        ],
      ),
    );
  }

  final _navigatorKey = GlobalKey<NavigatorState>();

  void _showPopup() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.9
          ),
          child: Navigator(
            key: _navigatorKey,
            pages: [
              MaterialPage(
                  child: Column(
                children: [
                  const Text('Title'),
                  TextButton(
                    onPressed: () {
                      _navigatorKey.currentState?.push(MaterialPageRoute(
                        builder: (_) => const SecondPage(),
                      ));
                    },
                    child: const Text('Go Next Page'),
                  ),
                ],
              )),
            ],
            onPopPage: (route, result) => true,
          ),
        );
      },
    );
  }
}
