import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../auth/auth_provider.dart';
import '../auth/login_screen.dart';
import '../projects/projects_screen.dart';
import '../attendance/attendance_screen.dart';
import '../progress/progress_screen.dart';
import '../more/more_screen.dart';
import '../widgets/animated_bottom_nav_bar.dart';
import 'dashboard_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardHomeScreen(),
    const ProjectsScreen(),
    const AttendanceScreen(), // Pointage
    const ProgressScreen(), // Avancement
    const MoreScreen(), // Plus
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: AnimatedBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          NavBarItem(
            icon: Icons.dashboard,
            label: 'Dashboard',
          ),
          NavBarItem(
            icon: Icons.construction,
            label: 'Projets',
          ),
          NavBarItem(
            icon: Icons.access_time,
            label: 'Pointage',
          ),
          NavBarItem(
            icon: Icons.trending_up,
            label: 'Avancement',
          ),
          NavBarItem(
            icon: Icons.more_horiz,
            label: 'Plus',
          ),
        ],
      ),
    );
  }
}

class DashboardHomeScreen extends StatefulWidget {
  const DashboardHomeScreen({super.key});

  @override
  State<DashboardHomeScreen> createState() => _DashboardHomeScreenState();
}

class _DashboardHomeScreenState extends State<DashboardHomeScreen> {
  int _selectedTab = 0; // 0: Projets, 1: Budget, 2: Avancement

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeDashboard();
    });
  }

  Future<void> _initializeDashboard() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // S'assurer que l'utilisateur est bien chargé
    if (!authProvider.isAuthenticated) {
      await authProvider.loadUser();
    }
    
    // Vérifier à nouveau après le chargement
    if (authProvider.isAuthenticated && mounted) {
      // Charger les données du dashboard seulement si authentifié
      Provider.of<DashboardProvider>(context, listen: false).loadDashboardData();
    } else if (mounted) {
      // Si pas authentifié, rediriger vers la page de connexion
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFB41839), // Rouge
                Color(0xFF3F1B3D), // Violet foncé
              ],
            ),
          ),
        ),
        title: const Text(
          'Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Bouton de notification animé
          _AnimatedNotificationButton(),
        ],
      ),
      body: Consumer2<DashboardProvider, AuthProvider>(
        builder: (context, dashboardProvider, authProvider, _) {
          // Vérifier l'authentification
          if (!authProvider.isAuthenticated) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Non authentifié',
                    style: TextStyle(color: Colors.red, fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    },
                    child: const Text('Se connecter'),
                  ),
                ],
              ),
            );
          }

          // Vérifier si l'utilisateur est vérifié
          if (!authProvider.isVerified && !authProvider.user!.isSuperAdmin) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.access_time,
                    size: 64,
                    color: Colors.orange[400],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Compte en attente de validation',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'Votre compte est en attente de validation par l\'administrateur. Vous recevrez un email une fois votre compte validé.',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      await authProvider.logout();
                      if (mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                          (route) => false,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB41839),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    child: const Text(
                      'Se déconnecter',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          }

          if (dashboardProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (dashboardProvider.errorMessage != null) {
            final errorMessage = dashboardProvider.errorMessage!.toLowerCase();
            // Vérifier si c'est une erreur d'authentification
            if (errorMessage.contains('unauth') || 
                errorMessage.contains('non authentifié') ||
                errorMessage.contains('token')) {
              // Rediriger vers la page de connexion
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              });
              return const Center(child: CircularProgressIndicator());
            }

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dashboardProvider.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      dashboardProvider.loadDashboardData();
                    },
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Statistiques principales fixes (ne scrollent pas)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard3D(
                            title: 'Total Projets',
                            value: dashboardProvider.totalProjects.toString(),
                            icon: Icons.construction,
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF4A90E2),
                                Color(0xFF357ABD),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard3D(
                            title: 'Projets Actifs',
                            value: dashboardProvider.activeProjects.toString(),
                            icon: Icons.check_circle,
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF2ECC71),
                                Color(0xFF27AE60),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard3D(
                            title: 'Budget Total',
                            value: '${dashboardProvider.totalBudget.toStringAsFixed(0)} FCFA',
                            icon: Icons.currency_exchange,
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFFF39C12),
                                Color(0xFFE67E22),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard3D(
                            title: 'Avancement Moyen',
                            value: '${dashboardProvider.averageProgress.toStringAsFixed(1)}%',
                            icon: Icons.trending_up,
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF9B59B6),
                                Color(0xFF8E44AD),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Contenu scrollable
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => dashboardProvider.loadDashboardData(),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        // Graphique avec onglets
                        _ChartCardWithTabs(
                          selectedTab: _selectedTab,
                          onTabChanged: (index) {
                            setState(() {
                              _selectedTab = index;
                            });
                          },
                          dashboardProvider: dashboardProvider,
                        ),
                        const SizedBox(height: 24),
                        
                        // Répartition par statut avec design 3D
                        _DistributionCard3D(
                          activeProjects: dashboardProvider.activeProjects,
                          completedProjects: dashboardProvider.completedProjects,
                          blockedProjects: dashboardProvider.blockedProjects,
                          totalProjects: dashboardProvider.totalProjects,
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Bouton de notification animé
class _AnimatedNotificationButton extends StatefulWidget {
  const _AnimatedNotificationButton();

  @override
  State<_AnimatedNotificationButton> createState() => _AnimatedNotificationButtonState();
}

class _AnimatedNotificationButtonState extends State<_AnimatedNotificationButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  final int _notificationCount = 3; // Nombre de notifications (exemple)

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    
    _rotationAnimation = Tween<double>(begin: -0.1, end: 0.1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    
    // Démarrer l'animation continue si il y a des notifications
    if (_notificationCount > 0) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    // Animation rapide au clic en plus de l'animation continue
    _controller.stop();
    _controller.reset();
    _controller.forward().then((_) {
      _controller.reverse().then((_) {
        // Reprendre l'animation continue si il y a des notifications
        if (_notificationCount > 0) {
          _controller.repeat(reverse: true);
        }
      });
    });
    // TODO: Naviguer vers la page de notifications
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Icône de notification avec animation
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Transform.rotate(
                    angle: _rotationAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: const Icon(
                        Icons.notifications_outlined,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                );
              },
            ),
            // Badge de notification
            if (_notificationCount > 0)
              Positioned(
                right: 0,
                top: 4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withValues(alpha: 0.5),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    _notificationCount > 9 ? '9+' : '$_notificationCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Carte de statistique avec effet 3D
class _StatCard3D extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Gradient gradient;

  const _StatCard3D({
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey[50]!,
            ],
          ),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             // Icône avec background en dégradé
             Container(
               padding: const EdgeInsets.all(10),
               decoration: BoxDecoration(
                 borderRadius: BorderRadius.circular(10),
                 gradient: gradient,
                 boxShadow: [
                   BoxShadow(
                     color: gradient.colors.first.withValues(alpha: 0.3),
                     blurRadius: 6,
                     offset: const Offset(0, 3),
                   ),
                 ],
               ),
               child: Icon(
                 icon,
                 color: Colors.white,
                 size: 20,
               ),
             ),
             const SizedBox(height: 12),
             Text(
               title,
               style: TextStyle(
                 fontSize: 11,
                 color: Colors.grey[600],
                 fontWeight: FontWeight.w500,
               ),
             ),
             const SizedBox(height: 4),
             Text(
               value,
               style: const TextStyle(
                 fontSize: 20,
                 fontWeight: FontWeight.bold,
                 color: Colors.black87,
                 letterSpacing: -0.5,
               ),
             ),
          ],
        ),
      ),
    );
  }
}

// Carte de graphique avec onglets
class _ChartCardWithTabs extends StatelessWidget {
  final int selectedTab;
  final Function(int) onTabChanged;
  final DashboardProvider dashboardProvider;

  const _ChartCardWithTabs({
    required this.selectedTab,
    required this.onTabChanged,
    required this.dashboardProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Onglets
            Row(
              children: [
                _TabButton(
                  label: 'Projets',
                  isSelected: selectedTab == 0,
                  onTap: () => onTabChanged(0),
                ),
                const SizedBox(width: 16),
                _TabButton(
                  label: 'Budget',
                  isSelected: selectedTab == 1,
                  onTap: () => onTabChanged(1),
                ),
                const SizedBox(width: 16),
                _TabButton(
                  label: 'Avancement',
                  isSelected: selectedTab == 2,
                  onTap: () => onTabChanged(2),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Graphique
            SizedBox(
              height: 180,
              child: _buildChart(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    // Données d'exemple pour les 6 derniers mois
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
    
    List<FlSpot> spots;
    Color lineColor;

    switch (selectedTab) {
      case 0: // Projets
        spots = [
          FlSpot(0, dashboardProvider.totalProjects * 0.3),
          FlSpot(1, dashboardProvider.totalProjects * 0.2),
          FlSpot(2, dashboardProvider.totalProjects * 0.5),
          FlSpot(3, dashboardProvider.totalProjects.toDouble()),
          FlSpot(4, dashboardProvider.totalProjects * 0.4),
          FlSpot(5, dashboardProvider.totalProjects * 0.7),
        ];
        lineColor = const Color(0xFFB41839); // Rouge du thème
        break;
      case 1: // Budget
        final maxBudget = dashboardProvider.totalBudget > 0 
            ? dashboardProvider.totalBudget 
            : 1000000;
        spots = [
          FlSpot(0, (maxBudget * 0.3) / 1000000),
          FlSpot(1, (maxBudget * 0.2) / 1000000),
          FlSpot(2, (maxBudget * 0.5) / 1000000),
          FlSpot(3, maxBudget / 1000000),
          FlSpot(4, (maxBudget * 0.4) / 1000000),
          FlSpot(5, (maxBudget * 0.7) / 1000000),
        ];
        lineColor = const Color(0xFFB41839); // Rouge du thème
        break;
      case 2: // Avancement
        spots = [
          FlSpot(0, dashboardProvider.averageProgress * 0.3),
          FlSpot(1, dashboardProvider.averageProgress * 0.2),
          FlSpot(2, dashboardProvider.averageProgress * 0.5),
          FlSpot(3, dashboardProvider.averageProgress.toDouble()),
          FlSpot(4, dashboardProvider.averageProgress * 0.4),
          FlSpot(5, dashboardProvider.averageProgress * 0.7),
        ];
        lineColor = const Color(0xFFB41839); // Rouge du thème
        break;
      default:
        spots = [];
        lineColor = const Color(0xFFB41839); // Rouge du thème
    }

    // Calculer maxY en s'assurant qu'il n'est jamais zéro
    double maxY;
    if (spots.isEmpty) {
      maxY = 10.0;
    } else {
      final maxValue = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
      maxY = (maxValue * 1.2).clamp(1.0, double.infinity);
    }

    // S'assurer que horizontalInterval n'est jamais zéro
    final horizontalInterval = (maxY / 4).clamp(1.0, double.infinity);

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: horizontalInterval,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey[200]!,
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < months.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      months[index],
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(color: Colors.grey[300]!),
            left: BorderSide(color: Colors.grey[300]!),
          ),
        ),
        minX: 0,
        maxX: 5,
        minY: 0,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: lineColor,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Colors.white,
                  strokeWidth: 2,
                  strokeColor: lineColor,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: lineColor.withValues(alpha: 0.1),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: lineColor,
            tooltipRoundedRadius: 8,
          ),
        ),
      ),
    );
  }
}

// Bouton d'onglet
class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected 
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFB41839), // Rouge
                    Color(0xFF3F1B3D), // Violet foncé
                  ],
                )
              : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

// Carte de répartition avec design 3D
class _DistributionCard3D extends StatelessWidget {
  final int activeProjects;
  final int completedProjects;
  final int blockedProjects;
  final int totalProjects;

  const _DistributionCard3D({
    required this.activeProjects,
    required this.completedProjects,
    required this.blockedProjects,
    required this.totalProjects,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Répartition des Projets',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 16),
            _ProgressBar3D(
              label: 'En cours',
              value: activeProjects,
              total: totalProjects,
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF4A90E2),
                  Color(0xFF357ABD),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _ProgressBar3D(
              label: 'Terminés',
              value: completedProjects,
              total: totalProjects,
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF2ECC71),
                  Color(0xFF27AE60),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _ProgressBar3D(
              label: 'Bloqués',
              value: blockedProjects,
              total: totalProjects,
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFE74C3C),
                  Color(0xFFC0392B),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Barre de progression avec design 3D
class _ProgressBar3D extends StatelessWidget {
  final String label;
  final int value;
  final int total;
  final Gradient gradient;

  const _ProgressBar3D({
    required this.label,
    required this.value,
    required this.total,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = total > 0 ? (value / total * 100) : 0.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: gradient,
                boxShadow: [
                  BoxShadow(
                    color: gradient.colors.first.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                '$value',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 12,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.grey[200],
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              children: [
                // Fond
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.grey[200],
                ),
                // Barre de progression avec dégradé
                FractionallySizedBox(
                  widthFactor: percentage / 100,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: gradient,
                      boxShadow: [
                        BoxShadow(
                          color: gradient.colors.first.withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
