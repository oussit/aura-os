
import 'dart:math';
import 'package:flutter/material.dart';

class Particle {
  Offset position;
  Offset velocity;
  double size;
  double opacity;
  Color color;
  double life;
  double maxLife;
  ParticleType type;

  Particle({
    required this.position,
    required this.velocity,
    this.size = 2,
    this.opacity = 1,
    this.color = Colors.white,
    this.life = 1,
    this.maxLife = 1,
    this.type = ParticleType.dot,
  });

  bool get isDead => life <= 0;
}

enum ParticleType { dot, glow, spark, snow, rain, fire, smoke, star }

class ParticleEngine extends StatefulWidget {
  final int particleCount;
  final ParticleType type;
  final Color? color;
  final List<Color>? colors;
  final double speed;
  final double size;
  final bool interactive;
  final Widget? child;

  const ParticleEngine({
    super.key,
    this.particleCount = 100,
    this.type = ParticleType.glow,
    this.color,
    this.colors,
    this.speed = 1,
    this.size = 3,
    this.interactive = false,
    this.child,
  });

  @override
  State<ParticleEngine> createState() => _ParticleEngineState();
}

class _ParticleEngineState extends State<ParticleEngine>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Particle> _particles;
  final Random _random = Random();
  Offset _touchPosition = Offset.zero;
  Offset _tiltOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16), // ~60fps
    )..addListener(_update);
    _particles = [];
    _initParticles();
    _controller.repeat();
  }

  void _initParticles() {
    for (int i = 0; i < widget.particleCount; i++) {
      _particles.add(_createParticle());
    }
  }

  Particle _createParticle() {
    final colors = widget.colors ?? [widget.color ?? Colors.white];
    return Particle(
      position: Offset(
        _random.nextDouble() * 400,
        _random.nextDouble() * 800,
      ),
      velocity: _getVelocity(),
      size: widget.size * (0.5 + _random.nextDouble()),
      opacity: 0.3 + _random.nextDouble() * 0.7,
      color: colors[_random.nextInt(colors.length)],
      life: 0.5 + _random.nextDouble() * 2,
      maxLife: 0.5 + _random.nextDouble() * 2,
      type: widget.type,
    );
  }

  Offset _getVelocity() {
    switch (widget.type) {
      case ParticleType.rain:
        return Offset(0, 4 * widget.speed);
      case ParticleType.snow:
        return Offset(
          (_random.nextDouble() - 0.5) * widget.speed,
          0.5 + _random.nextDouble() * widget.speed,
        );
      case ParticleType.fire:
        return Offset(
          (_random.nextDouble() - 0.5) * widget.speed,
          -2 - _random.nextDouble() * 3 * widget.speed,
        );
      case ParticleType.smoke:
        return Offset(
          (_random.nextDouble() - 0.5) * 0.5 * widget.speed,
          -0.5 - _random.nextDouble() * widget.speed,
        );
      case ParticleType.spark:
        final angle = _random.nextDouble() * 2 * pi;
        final speed = 1 + _random.nextDouble() * 3 * widget.speed;
        return Offset(cos(angle) * speed, sin(angle) * speed);
      default:
        return Offset(
          (_random.nextDouble() - 0.5) * widget.speed,
          (_random.nextDouble() - 0.5) * widget.speed,
        );
    }
  }

  void _update() {
    if (!mounted) return;
    setState(() {
      for (var p in _particles) {
        p.position += p.velocity;
        p.life -= 0.016;
        
        // Apply tilt offset for parallax
        if (widget.interactive) {
          p.position += _tiltOffset * 0.1;
        }

        // Wrap around or respawn
        if (p.isDead || p.position.dy > 900 || p.position.dy < -50 ||
            p.position.dx > 500 || p.position.dx < -50) {
          final idx = _particles.indexOf(p);
          _particles[idx] = _createParticle();
          _particles[idx].position = _getSpawnPosition();
        }
      }
    });
  }

  Offset _getSpawnPosition() {
    switch (widget.type) {
      case ParticleType.rain:
      case ParticleType.snow:
        return Offset(_random.nextDouble() * 400, -10);
      case ParticleType.fire:
        return Offset(150 + _random.nextDouble() * 100, 800);
      default:
        return Offset(_random.nextDouble() * 400, _random.nextDouble() * 800);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: widget.interactive
          ? (d) => setState(() => _touchPosition = d.localPosition)
          : null,
      child: CustomPaint(
        painter: _ParticlePainter(
          particles: _particles,
          type: widget.type,
        ),
        size: Size.infinite,
        child: widget.child,
      ),
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final ParticleType type;

  _ParticlePainter({required this.particles, required this.type});

  @override
  void paint(Canvas canvas, Size size) {
    for (var p in particles) {
      final paint = Paint()
        ..color = p.color.withOpacity(p.opacity * (p.life / p.maxLife))
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          type == ParticleType.glow ? p.size * 2 : 0,
        );

      switch (type) {
        case ParticleType.rain:
          canvas.drawLine(
            p.position,
            p.position + Offset(0, p.size * 4),
            paint..strokeWidth = 1,
          );
          break;
        case ParticleType.smoke:
          canvas.drawCircle(p.position, p.size * (1 + (1 - p.life / p.maxLife) * 2), paint);
          break;
        case ParticleType.star:
          _drawStar(canvas, p.position, p.size, paint);
          break;
        default:
          canvas.drawCircle(p.position, p.size, paint);
      }
    }
  }

  void _drawStar(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final angle = (i * 4 * pi / 5) - pi / 2;
      final point = center + Offset(cos(angle) * size, sin(angle) * size);
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
