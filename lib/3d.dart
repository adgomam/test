import 'package:flutter/material.dart';
import 'package:babylonjs_viewer/babylonjs_viewer.dart';

class ThreeD extends StatefulWidget {
  const ThreeD({Key? key,
  }) : super(key: key);


  @override
  ThreeDState createState() => ThreeDState();
}

class ThreeDState extends State<ThreeD> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Take a picture')),
      body: SizedBox(
        height: 300,
        width: 300,
        child: BabylonJSViewer(
          src: 'assets/images/test1.glb',
        ),
      ),
    );
  }
}