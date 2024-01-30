import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/src/scheduler/ticker.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ColorPalette.oceanicNoir.color,
                    ColorPalette.mysticMint.color,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: const Center(
                child: GameWidget(),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      color: Colors.black,
                    ),
                    children: [
                      TextSpan(
                        text: 'Made with 💙 in Singapore. ',
                      ),
                      TextSpan(text: 'Inspired by '),
                      TextSpan(
                        text: 'Pong Wars',
                        style: TextStyle(decoration: TextDecoration.underline),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RepaintNotifier extends ChangeNotifier {
  void markNeedsPaint() {
    notifyListeners();
  }
}

class GameWidget extends StatefulWidget {
  const GameWidget({super.key});

  @override
  State<GameWidget> createState() => _GameWidgetState();
}

class _GameWidgetState extends State<GameWidget> with TickerProviderStateMixin {
  late Ticker _ticker;
  final RepaintNotifier _repaint = RepaintNotifier();
  (int, int) score = (0, 0);

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((_) => gameLoop());
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void gameLoop() {
    _repaint.markNeedsPaint();
  }

  @override
  Widget build(BuildContext context) {
    final side = MediaQuery.of(context).size.shortestSide - 200;
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: side,
          height: side,
          child: CustomPaint(
            painter: Game(
              repaint: _repaint,
              onScoreUpdate: (dayScore, nightScore) {
                score = (dayScore, nightScore);
              },
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              'Day: ${score.$1}',
              style: const TextStyle(
                fontSize: 24,
              ),
            ),
            Text(
              'Night: ${score.$2}',
              style: const TextStyle(
                fontSize: 24,
              ),
            ),
          ],
        ),
      ],
    );
    // return Text(DateTime.now().toString());
  }
}

enum ColorPalette {
  arcticPowder(Color(0xFFF1F6F4)),
  mysticMint(Color(0xFFD9E8E3)),
  forsythia(Color(0xFFFFC801)),
  deepSaffron(Color(0xFFFF9932)),
  nocturnalExpedition(Color(0xFF114C5A)),
  oceanicNoir(Color(0xFF172B36));

  final Color color;

  const ColorPalette(this.color);
}

class Game extends CustomPainter {
  static const dayColor = ColorPalette.mysticMint;
  static const dayBallColor = ColorPalette.nocturnalExpedition;
  static const nightColor = ColorPalette.nocturnalExpedition;
  static const nightBallColor = ColorPalette.mysticMint;
  static const squareSize = 25.0;

  final void Function(int, int)? onScoreUpdate;

  double x1 = 0;
  double y1 = 0;
  double dx1 = 0;
  double dy1 = 0;

  double x2 = 0;
  double y2 = 0;
  double dx2 = 0;
  double dy2 = 0;

  int iteration = 0;

  List<List<ColorPalette>> squares = [];

  Game({super.repaint, this.onScoreUpdate});

  @override
  void paint(Canvas canvas, Size size) {
    final numSquaresX = size.width ~/ squareSize;
    final numSquaresY = size.height ~/ squareSize;

    for (int i = 0; i < numSquaresX; i++) {
      squares.add([]);
      for (int j = 0; j < numSquaresY; j++) {
        squares[i].add(i < numSquaresX / 2 ? dayColor : nightColor);
      }
    }

    if (iteration == 0) {
      x1 = size.width / 4;
      y1 = size.height / 2;
      dx1 = 12.5;
      dy1 = -12.5;

      x2 = (size.width / 4) * 3;
      y2 = size.height / 2;
      dx2 = -12.5;
      dy2 = 12.5;
    }

    void drawBall(double x, double y, ColorPalette color) {
      Paint paint = Paint()..color = color.color;
      canvas.drawCircle(Offset(x, y), squareSize / 2, paint);
    }

    void drawSquares() {
      for (int i = 0; i < numSquaresX; i++) {
        for (int j = 0; j < numSquaresY; j++) {
          Paint square = Paint();
          square.color = squares[i][j].color;
          canvas.drawRect(
            Rect.fromPoints(
              Offset(i * squareSize, j * squareSize),
              Offset((i + 1) * squareSize, (j + 1) * squareSize),
            ),
            square,
          );
        }
      }
    }

    (double dx, double dy) updateSquareAndBounce(double x, double y, double dx, double dy, ColorPalette color) {
      double updatedDx = dx;
      double updatedDy = dy;

      // Check multiple points around the ball's circumference
      for (double angle = 0; angle < 2 * math.pi; angle += math.pi / 4) {
        double checkX = x + math.cos(angle) * (squareSize / 2);
        double checkY = y + math.sin(angle) * (squareSize / 2);

        int i = (checkX / squareSize).floor();
        int j = (checkY / squareSize).floor();

        if (i >= 0 && i < numSquaresX && j >= 0 && j < numSquaresY) {
          if (squares[i][j] != color) {
            squares[i][j] = color;

            // Determine bounce direction based on the angle
            if (math.cos(angle).abs() > math.sin(angle).abs()) {
              updatedDx = -updatedDx;
            } else {
              updatedDy = -updatedDy;
            }
          }
        }
      }

      return (updatedDx, updatedDy);
    }

    void updateScoreElement() {
      int dayScore = 0;
      int nightScore = 0;
      for (int i = 0; i < numSquaresX; i++) {
        for (int j = 0; j < numSquaresY; j++) {
          if (squares[i][j] == dayColor) {
            dayScore++;
          } else if (squares[i][j] == nightColor) {
            nightScore++;
          }
        }
      }

      onScoreUpdate?.call(dayScore, nightScore);
    }

    (double dx, double dy) checkBoundaryCollision(double x, double y, double dx, double dy) {
      if (x + dx > size.width - squareSize / 2 || x + dx < squareSize / 2) {
        dx = -dx;
      }
      if (y + dy > size.height - squareSize / 2 || y + dy < squareSize / 2) {
        dy = -dy;
      }

      return (dx, dy);
    }

    void draw() {
      print('drawing...');
      drawSquares();

      drawBall(x1, y1, dayBallColor);
      var bounce1 = updateSquareAndBounce(x1, y1, dx1, dy1, dayColor);
      dx1 = bounce1.$1;
      dy1 = bounce1.$2;

      drawBall(x2, y2, nightBallColor);
      var bounce2 = updateSquareAndBounce(x2, y2, dx2, dy2, nightColor);
      dx2 = bounce2.$1;
      dy2 = bounce2.$2;

      var boundary1 = checkBoundaryCollision(x1, y1, dx1, dy1);
      dx1 = boundary1.$1;
      dy1 = boundary1.$2;

      var boundary2 = checkBoundaryCollision(x2, y2, dx2, dy2);
      dx2 = boundary2.$1;
      dy2 = boundary2.$2;

      x1 += dx1;
      y1 += dy1;
      x2 += dx2;
      y2 += dy2;

      iteration++;

      updateScoreElement();
    }

    draw();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  Color getRandomColor() {
    return Color((math.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
  }
}
