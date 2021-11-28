import 'dart:async';
import 'dart:typed_data';
import "dart:ui" as ui;

import "package:flutter/material.dart";
import 'package:flutter/services.dart' show rootBundle;

import "package:flutter_nes/flutter_nes.dart";

void main() {
  runApp(const FicoApp());
}

Future<ui.Image> frameToImage(Uint8List frame) {
  final Completer<ui.Image> _completer = new Completer();

  ui.decodeImageFromPixels(frame, 256, 240, ui.PixelFormat.rgba8888, (image) {
    _completer.complete(image);
  });

  return _completer.future;
}

// paint one frame from nes emulator
class NesImagePainter extends CustomPainter {
  NesImagePainter(this.image);

  ui.Image? image;
  final painter = Paint();

  @override
  void paint(Canvas canvas, Size size) async {
    if (image == null) return;

    canvas.drawImageRect(
        image!,
        Rect.fromLTWH(0, 0, image!.width.toDouble(), image!.height.toDouble()),
        Rect.fromLTWH(0, 0, size.width, size.height),
        painter);
  }

  @override
  bool shouldRepaint(covariant NesImagePainter oldDelegate) {
    return image != oldDelegate.image;
  }
}

class NesScreenState extends State {
  NesEmulator emulator = NesEmulator();

  ui.Image? image;

  @override
  void initState() {
    super.initState();

    loadGame();
  }

  loadGame() async {
    final ByteData game = await rootBundle.load('roms/Bomber_man.nes');

    emulator.loadGame(game.buffer.asUint8List());
    emulator.powerOn();

    emulator.on('FrameDone', (newFrame) async {
      final ui.Image newImage = await frameToImage(newFrame.pixels);

      setState(() {
        image = newImage;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        color: Colors.white,
        child: CustomPaint(painter: NesImagePainter(image)),
      ),
    );
  }
}

class NesScreen extends StatefulWidget {
  const NesScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => NesScreenState();
}

class FicoApp extends StatelessWidget {
  const FicoApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const NesScreen();
  }
}
