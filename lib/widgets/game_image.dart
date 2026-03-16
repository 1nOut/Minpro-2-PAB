import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GameImage extends StatelessWidget {
  final String logo;
  final double size;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const GameImage({
    super.key,
    required this.logo,
    this.size = 55,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  static String resolvePath(String logo) {
    if (logo.startsWith('http')) return logo;
    if (logo.startsWith('assets/')) return logo;
    if (logo.contains('ml')) return 'assets/image/ml.png';
    if (logo.contains('ff')) return 'assets/image/ff.png';
    if (logo.contains('pubg')) return 'assets/image/pubgm.png';
    return 'assets/image/ml.png';
  }

  bool get _isNetwork => logo.startsWith('http');

  @override
  Widget build(BuildContext context) {
    final br = borderRadius ?? AppTheme.radiusMedium;

    if (_isNetwork) {
      return ClipRRect(
        borderRadius: br,
        child: Image.network(
          logo,
          width: size,
          height: size,
          fit: fit,
          loadingBuilder: (_, child, progress) {
            if (progress == null) return child;
            return Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: br,
              ),
              child: Center(
                child: SizedBox(
                  width: size * 0.4,
                  height: size * 0.4,
                  child: CircularProgressIndicator(
                    value: progress.expectedTotalBytes != null
                        ? progress.cumulativeBytesLoaded /
                            progress.expectedTotalBytes!
                        : null,
                    strokeWidth: 2,
                    color: AppTheme.primaryLight,
                  ),
                ),
              ),
            );
          },
          errorBuilder: (_, __, ___) => _placeholder(br),
        ),
      );
    }

    return ClipRRect(
      borderRadius: br,
      child: Image.asset(
        resolvePath(logo),
        width: size,
        height: size,
        fit: fit,
        errorBuilder: (_, __, ___) => _placeholder(br),
      ),
    );
  }

  Widget _placeholder(BorderRadius br) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.1),
        borderRadius: br,
      ),
      child: Icon(
        Icons.games_rounded,
        color: AppTheme.primaryLight,
        size: size * 0.5,
      ),
    );
  }
}
