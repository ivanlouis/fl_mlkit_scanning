import 'package:example/camera_scan.dart';
import 'package:example/image_scan.dart';
import 'package:example/mlkit_scanning.dart';
import 'package:fl_mlkit_scanning/fl_mlkit_scanning.dart';
import 'package:flutter/material.dart';
import 'package:flutter_curiosity/flutter_curiosity.dart';
import 'package:flutter_waya/flutter_waya.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(ExtendedWidgetsApp(home: _App()));
}

class _App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<_App> {
  List<Barcode> list = <Barcode>[];

  @override
  Widget build(BuildContext context) {
    return ExtendedScaffold(
        appBar: AppBarText('Fl MlKit Scanning'),
        mainAxisAlignment: MainAxisAlignment.center,
        padding: const EdgeInsets.all(30),
        children: <Widget>[
          ElevatedText(
              onPressed: openCamera, text: 'Turn on camera recognition'),
          const SizedBox(height: 10),
          ElevatedText(onPressed: scanImage, text: 'Image recognition'),
          const SizedBox(height: 30),
          ShowCode(list)
        ]);
  }

  void scanImage() {
    push(const ImageScanPage());
  }

  Future<void> scanCamera() async {
    if (!isMobile) return;
    final bool permission = await getPermission(Permission.camera);
    if (permission) push(const CameraScanPage());
  }

  Future<void> openCamera() async {
    bool hasPermission = false;
    if (isAndroid) hasPermission = await getPermission(Permission.camera);
    if (isIOS) hasPermission = true;
    if (hasPermission) {
      print("log has permission");
      final List<Barcode>? data = await push(const FlMlKitScanningPage());
      if (data != null) {
        list = data;
        setState(() {});
      }
    }
  }
}

class ShowCode extends StatelessWidget {
  const ShowCode(this.list, {Key? key, this.expanded = true}) : super(key: key);
  final List<Barcode> list;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    return Universal(
        expanded: expanded,
        isScroll: expanded,
        children: list.builderEntry((MapEntry<int, Barcode> entry) {
          return Column(children: <Widget>[
            Text('NO.${entry.key + 1}'),
            const SizedBox(height: 6),
            Text('value:${entry.value.value}').sizedBox(width: double.infinity),
            const SizedBox(height: 6),
            Text('type:${entry.value.type}').sizedBox(width: double.infinity),
            Text('boundingBox:${entry.value.boundingBox?.size}')
                .sizedBox(width: double.infinity),
            Text('boundingBox:${entry.value.boundingBox}')
                .sizedBox(width: double.infinity),
            Text('corners:${entry.value.corners}')
                .sizedBox(width: double.infinity),
          ]);
        }));
  }
}

class AppBarText extends AppBar {
  AppBarText(String text, {Key? key})
      : super(
            key: key,
            elevation: 0,
            title: BText(text,
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            centerTitle: true);
}

class ShowText extends StatelessWidget {
  final dynamic keyName;
  final dynamic value;

  const ShowText(this.keyName, this.value, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Visibility(
        visible: value != null &&
            value.toString().isNotEmpty &&
            value.toString() != 'null',
        child: Container(
            margin: const EdgeInsets.all(10),
            child: Text('$keyName = $value')));
  }
}

Future<bool> getPermission(Permission permission) async {
  PermissionStatus status = await permission.status;
  if (status.isGranted) {
    return true;
  } else {
    status = await permission.request();
    if (!status.isGranted) openAppSettings();
    return status.isGranted;
  }
}

class ElevatedText extends StatelessWidget {
  const ElevatedText({Key? key, this.onPressed, required this.text})
      : super(key: key);
  final VoidCallback? onPressed;
  final String text;

  @override
  Widget build(BuildContext context) =>
      ElevatedButton(onPressed: onPressed, child: Text(text));
}

class ElevatedIcon extends StatelessWidget {
  const ElevatedIcon({Key? key, this.onPressed, required this.icon})
      : super(key: key);
  final VoidCallback? onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) => ElevatedButton(
      onPressed: onPressed, child: Icon(icon, color: Colors.white));
}
