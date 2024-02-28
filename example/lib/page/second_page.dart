import 'package:flutter/material.dart';
import 'package:flutter_annotation_router/flutter_annotation_router.dart';
import '../route/router.navigate.dart';
import '../json/user.dart';

@RoutePage('/second',
    toSelfAndPopTo: true,
    replacementToSelf: true,
    backToSelf: true,
    popAndToSelf: true)
class SecondPage extends StatelessWidget {
  @RouteValue()
  final UserInfo? userInfo;

  const SecondPage({Key? key, this.userInfo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Second')),
      body: Column(
        children: [
          TextButton(
            onPressed: () => context.backToHome(),
            child: const Text('Go Home'),
          ),
        ],
      ),
    );
  }
}
