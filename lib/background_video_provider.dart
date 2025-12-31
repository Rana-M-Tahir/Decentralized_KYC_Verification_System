import 'package:flutter/material.dart';
import 'dart:math';

class BackgroundVideoProvider extends ChangeNotifier {
  late AnimationController _animationController;
  TickerProvider? _vsync;
  List<BlockchainNode> _nodes = [];
  final Random _random = Random();
  bool _isInitialized = false;

  // Animation state
  double _time = 0.0;
  List<Connection> _connections = [];

  // Customization options
  Color _primaryColor = const Color(0xFF0D1B2A); // Very dark blue
  Color _secondaryColor = const Color(0xFF1B263B);
  int _nodeCount = 25;
  double _animationSpeed = 1.0;

  // Getters
  bool get isInitialized => _isInitialized;
  double get time => _time;
  List<BlockchainNode> get nodes => _nodes;
  List<Connection> get connections => _connections;

  // For backward compatibility with your login screen
  // (These are dummy getters to match your existing video code)
  bool get controller => true; // Dummy for videoProvider.controller
  bool get video => true; // Dummy for Video widget

  void initialize(TickerProvider vsync) {
    _vsync = vsync;
    _initAnimation();
  }

  void _initAnimation() {
    if (_vsync == null) return;

    _animationController = AnimationController(
      duration: Duration(milliseconds: (30000 / _animationSpeed).round()),
      vsync: _vsync!,
    )
      ..addListener(() {
        _time = _animationController.value * 2 * pi;
        _updateAnimation();
        notifyListeners();
      })
      ..repeat();

    _initializeNodes();
    _isInitialized = true;
    notifyListeners();
  }

  void _initializeNodes() {
    _nodes = List.generate(_nodeCount, (index) {
      return BlockchainNode(
        id: index,
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        speed: 0.2 + _random.nextDouble() * 0.4,
        radius: 2 + _random.nextDouble() * 4,
        color: index % 3 == 0 ? _secondaryColor : _primaryColor,
        pulseOffset: _random.nextDouble() * 2 * pi,
      );
    });
  }

  void _updateAnimation() {
    // Update node positions
    for (var node in _nodes) {
      node.x += node.speed * 0.001 * _animationSpeed;
      node.y += sin(node.x * 2 * pi + _time) * 0.001 * _animationSpeed;

      // Wrap around edges
      if (node.x > 1.1) node.x = -0.1;
      if (node.x < -0.1) node.x = 1.1;
      if (node.y > 1.1) node.y = -0.1;
      if (node.y < -0.1) node.y = 1.1;
    }

    // Update connections
    _connections.clear();
    for (int i = 0; i < _nodes.length; i++) {
      for (int j = i + 1; j < _nodes.length; j++) {
        final dx = (_nodes[i].x - _nodes[j].x);
        final dy = (_nodes[i].y - _nodes[j].y);
        final distance = sqrt(dx * dx + dy * dy);

        if (distance < 0.3) {
          _connections.add(Connection(_nodes[i], _nodes[j]));
        }
      }
    }
  }

  // Helper method to create custom painter
  CustomPainter createPainter(Size size) {
    return _BlockchainAnimationPainter(
      nodes: _nodes,
      connections: _connections,
      time: _time,
      primaryColor: _primaryColor,
      secondaryColor: _secondaryColor,
    );
  }

  @override
  void dispose() {
    if (_isInitialized) {
      _animationController.dispose();
    }
    super.dispose();
  }
}

// Model classes
class BlockchainNode {
  final int id;
  double x, y;
  final double speed;
  final double radius;
  final Color color;
  final double pulseOffset;

  BlockchainNode({
    required this.id,
    required this.x,
    required this.y,
    required this.speed,
    required this.radius,
    required this.color,
    required this.pulseOffset,
  });
}

class Connection {
  final BlockchainNode a, b;

  Connection(this.a, this.b);
}

// Custom Painter
class _BlockchainAnimationPainter extends CustomPainter {
  final List<BlockchainNode> nodes;
  final List<Connection> connections;
  final double time;
  final Color primaryColor;
  final Color secondaryColor;

  _BlockchainAnimationPainter({
    required this.nodes,
    required this.connections,
    required this.time,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw gradient background
    final bgRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final bgGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF05051A), // Dark purple-blue
        Color(0xFF0A0A23), // Space blue
        Color(0xFF15153A),
      ],
    );
    canvas.drawRect(bgRect, Paint()..shader = bgGradient.createShader(bgRect));

    // Draw connections
    for (var connection in connections) {
      final dx = (connection.a.x - connection.b.x) * size.width;
      final dy = (connection.a.y - connection.b.y) * size.height;
      final distance = sqrt(dx * dx + dy * dy);

      final opacity = (1 - distance / 120).clamp(0.05, 0.2);
      final paint = Paint()
        ..color = connection.a.color.withOpacity(opacity)
        ..strokeWidth = 0.8;

      canvas.drawLine(
        Offset(connection.a.x * size.width, connection.a.y * size.height),
        Offset(connection.b.x * size.width, connection.b.y * size.height),
        paint,
      );
    }

    // Draw nodes
    for (final node in nodes) {
      final pulse = 1 + sin(time + node.pulseOffset) * 0.2;
      final radius = node.radius * pulse;
      final x = node.x * size.width;
      final y = node.y * size.height;

      // Glow effect
      final glowPaint = Paint()
        ..color = node.color.withOpacity(0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      // Main particle
      final particlePaint = Paint()
        ..color = node.color
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), radius + 3, glowPaint);
      canvas.drawCircle(Offset(x, y), radius, particlePaint);

      // Draw hash-like text for some nodes
      if (node.id % 6 == 0) {
        _drawHashTag(canvas, x, y, node.color);
      }
    }

    // Draw floating blockchain blocks
    _drawFloatingBlocks(canvas, size);
  }

  void _drawHashTag(Canvas canvas, double x, double y, Color color) {
    final rawValue =
        ((x + y) * 1000).toInt().abs(); // Use abs() to ensure positive
    final hexString = rawValue.toRadixString(16);

    // Pad the string to ensure it has at least 6 characters
    final paddedHex = hexString.padLeft(6, '0');

    // Now safely take the first 6 characters
    final hash = '0x${paddedHex.substring(0, 6)}';

    final textSpan = TextSpan(
      text: hash,
      style: TextStyle(
        color: color.withOpacity(0.6),
        fontSize: 8,
        fontFamily: 'Monospace',
        fontWeight: FontWeight.bold,
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(canvas, Offset(x + 12, y - 4));
  }

  void _drawFloatingBlocks(Canvas canvas, Size size) {
    final blockCount = 6;
    for (int i = 0; i < blockCount; i++) {
      final x = (time * 0.1 + i * 0.5) % 1.5 - 0.25;
      final y = 0.2 + sin(time * 0.5 + i) * 0.15;

      if (x > -0.1 && x < 1.1) {
        _drawBlock(canvas, x * size.width, y * size.height, i);
      }
    }
  }

  void _drawBlock(Canvas canvas, double x, double y, int index) {
    final colors = [
      Color(0xFF1B3A57), // Dark slate blue
      Color(0xFF2D4A6E), // Medium dark blue
      Color(0xFF3C5A80)
    ];

    final color = colors[index % colors.length].withOpacity(0.15);

    final blockPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = secondaryColor.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Block with rounded corners
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x, y, 45, 35),
      Radius.circular(4),
    );

    canvas.drawRRect(rect, blockPaint);
    canvas.drawRRect(rect, borderPaint);

    // Draw blockchain-like internal structure
    for (int i = 1; i < 4; i++) {
      canvas.drawLine(
        Offset(x + 8, y + i * 8),
        Offset(x + 37, y + i * 8),
        borderPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_BlockchainAnimationPainter oldDelegate) => true;
}
// Add this widget in a new file called 'blockchain_background.dart'
// OR add it at the bottom of background_video_provider.dart

class BlockchainBackground extends StatefulWidget {
  final Widget child;
  final BackgroundVideoProvider? provider;

  const BlockchainBackground({
    Key? key,
    required this.child,
    this.provider,
  }) : super(key: key);

  @override
  _BlockchainBackgroundState createState() => _BlockchainBackgroundState();
}

class _BlockchainBackgroundState extends State<BlockchainBackground>
    with SingleTickerProviderStateMixin {
  late BackgroundVideoProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = widget.provider ?? BackgroundVideoProvider();
    _provider.initialize(this);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _provider,
      builder: (context, child) {
        return Stack(
          children: [
            // Animated Background
            Positioned.fill(
              child: CustomPaint(
                painter: _provider.createPainter(Size.infinite),
              ),
            ),

            // Content overlay for readability (similar to video overlay)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF0A0A1E).withOpacity(0.9), // Darker overlay
                      Colors.transparent,
                      Color(0xFF0D1B2A).withOpacity(0.8),
                    ],
                  ),
                ),
              ),
            ),

            // Child content
            widget.child,
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }
}
