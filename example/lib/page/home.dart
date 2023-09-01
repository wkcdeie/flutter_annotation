import 'package:flutter/material.dart';
import 'package:flutter_annotation_router/flutter_annotation_router.dart';
import '../route/router.navigate.dart';
import '../config/app_config.dart';

@RoutePage('/', isRoot: true)
class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = AppConfig.instance.userName ?? 'nil';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              children: [
                Expanded(
                  child:TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Username',
                    ),
                  ),
                ),
                TextButton(
                  child: const Text('Save'),
                  onPressed: () {
                    AppConfig.instance.userName = _controller.text;
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
