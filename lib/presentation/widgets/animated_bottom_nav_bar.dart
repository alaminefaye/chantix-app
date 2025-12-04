import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<NavBarItem> items;

  const AnimatedBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  State<AnimatedBottomNavBar> createState() => _AnimatedBottomNavBarState();
}

class _AnimatedBottomNavBarState extends State<AnimatedBottomNavBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = (screenWidth - 32) / widget.items.length;
    final selectedPosition = (widget.currentIndex * itemWidth) + (itemWidth / 2) - 25;
    final circleRadius = 25.0;

    return Container(
      height: 90,
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 12, top: 25),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Barre de navigation avec courbe dessinée avec CustomPaint
          CustomPaint(
            painter: _NavBarPainter(
              selectedPosition: selectedPosition + circleRadius,
              circleRadius: circleRadius,
            ),
            child: Container(
              height: 65,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: widget.items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final isSelected = index == widget.currentIndex;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => widget.onTap(index),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        height: double.infinity,
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (!isSelected)
                              Icon(
                                item.icon,
                                color: Colors.white,
                                size: 24,
                              )
                            else
                              const SizedBox(height: 24),
                            const SizedBox(height: 4),
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 300),
                              style: TextStyle(
                                fontSize: isSelected ? 12 : 10, // Plus gros pour l'item actif
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: Colors.white, // Blanc pour tous les textes (actif et non actif)
                              ),
                              child: Text(
                                item.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          // Cercle animé
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            top: -circleRadius * 0.7,
            left: selectedPosition,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: circleRadius * 2,
                height: circleRadius * 2,
                decoration: BoxDecoration(
                  color: Colors.white, // Blanc pour un meilleur contraste
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: Icon(
                  widget.items[widget.currentIndex].icon,
                  color: const Color(0xFFB41839), // Rouge pour l'icône
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// CustomPainter pour dessiner la barre avec la courbe
class _NavBarPainter extends CustomPainter {
  final double selectedPosition;
  final double circleRadius;

  _NavBarPainter({
    required this.selectedPosition,
    required this.circleRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Créer un dégradé rouge vers violet foncé (comme splash et login)
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFFB41839), // Rouge
        const Color(0xFF3F1B3D), // Violet foncé
      ],
    );
    
    final paint = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();
    final barHeight = size.height;
    final barRadius = 30.0;
    final circleCenterX = selectedPosition;
    
    // Commencer par le coin inférieur gauche
    path.moveTo(0, barHeight);
    
    // Ligne de gauche vers le haut
    path.lineTo(0, barRadius);
    
    // Coin supérieur gauche
    path.quadraticBezierTo(0, 0, barRadius, 0);
    
    // Ligne du haut - avec courbe concave pour intégrer le cercle
    if (circleCenterX - circleRadius < size.width - barRadius &&
        circleCenterX + circleRadius > barRadius) {
      // Point de départ de la courbe (à gauche du cercle)
      final leftCurveStart = math.max(barRadius, circleCenterX - circleRadius);
      path.lineTo(leftCurveStart, 0);
      
      // Courbe concave prononcée (en forme de U)
      // Le cercle est à 70% au-dessus, donc 30% est dans la barre
      final circleInBar = circleRadius * 0.3;
      final curveDepth = circleInBar * 2.0; // Courbe très prononcée
      
      final leftPoint = circleCenterX - circleRadius;
      final centerPoint = circleCenterX;
      final rightPoint = circleCenterX + circleRadius;
      
      // Créer une courbe concave très visible
      path.cubicTo(
        leftPoint + circleRadius * 0.2,
        curveDepth * 0.3,
        centerPoint - circleRadius * 0.3,
        curveDepth,
        centerPoint,
        curveDepth,
      );
      
      path.cubicTo(
        centerPoint + circleRadius * 0.3,
        curveDepth,
        rightPoint - circleRadius * 0.2,
        curveDepth * 0.3,
        rightPoint,
        0,
      );
      
      if (rightPoint < size.width - barRadius) {
        path.lineTo(size.width - barRadius, 0);
      }
    } else {
      path.lineTo(size.width - barRadius, 0);
    }
    
    // Coin supérieur droit
    path.quadraticBezierTo(size.width, 0, size.width, barRadius);
    
    // Ligne de droite
    path.lineTo(size.width, barHeight - barRadius);
    
    // Coin inférieur droit
    path.quadraticBezierTo(size.width, barHeight, size.width - barRadius, barHeight);
    
    // Ligne du bas
    path.lineTo(barRadius, barHeight);
    
    // Coin inférieur gauche
    path.quadraticBezierTo(0, barHeight, 0, barHeight - barRadius);
    
    path.close();
    
    // Dessiner l'ombre (plus subtile avec le dégradé)
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    
    canvas.drawPath(path, shadowPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_NavBarPainter oldDelegate) {
    return oldDelegate.selectedPosition != selectedPosition;
  }
}

class NavBarItem {
  final IconData icon;
  final String label;

  const NavBarItem({
    required this.icon,
    required this.label,
  });
}
