import 'dart:typed_data';
import "dart:ui";

import "package:flutter/material.dart";
import 'package:flutter/services.dart' show rootBundle;

import "package:flutter_nes/flutter_nes.dart";
import "package:flutter_nes/frame.dart";

void main() {
  runApp(FicoApp());
}

dynamic createPixel(int x, int y) {
  const double scale = 2.0;
  return Offset(x * scale, y * scale) & Size(scale, scale);
}

// paint one frame from nes emulator
class NesFramePainter extends CustomPainter {
  NesFramePainter(this._frame);

  Frame _frame;

  @override
  void paint(Canvas canvas, Size size) {
    if (_frame == null) return;

    final paint = Paint();

    _frame.forEachPixel((x, y, color) {
      paint.color = Color(color);
      canvas.drawRect(createPixel(x, y), paint);
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class NesScreenState extends State {
  NesEmulator _emulator = NesEmulator();

  Frame frame = Frame();

  @override
  void initState() {
    super.initState();

    loadGame();
  }

  loadGame() async {
    final ByteData game =
        await rootBundle.load('roms/Super_mario_brothers.nes');

    _emulator.loadGame(game.buffer.asUint8List());
    _emulator.powerOn();

    _emulator.on('FrameDone', (newFrame) {
      setState(() {
        frame = newFrame;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        color: Colors.white,
        child: CustomPaint(painter: NesFramePainter(frame)),
      ),
    );
  }
}

class NesScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => NesScreenState();
}

class FicoApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return NesScreen();
  }
}
