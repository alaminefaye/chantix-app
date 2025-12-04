import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DashboardProvider>(context, listen: false).loadDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Dashboard',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              return PopupMenuButton(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: const Row(
                      children: [
                        Icon(Icons.person),
                        SizedBox(width: 8),
                        Text('Profil'),
                      ],
                    ),
                    onTap: () {
                      // TODO: Naviguer vers le profil
                    },
                  ),
                  PopupMenuItem(
                    child: const Row(
                      children: [
                        Icon(Icons.logout, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Déconnexion', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                    onTap: () async {
                      await authProvider.logout();
                      if (context.mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                          (route) => false,
                        );
                      }
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<DashboardProvider>(
        builder: (context, dashboardProvider, _) {
          if (dashboardProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (dashboardProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dashboardProvider.errorMessage!,
                    style: const TextStyle(color: Colors.red),
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

          return RefreshIndicator(
            onRefresh: () => dashboardProvider.loadDashboardData(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Statistiques principales avec design 3D
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
                      const SizedBox(width: 16),
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
                  const SizedBox(height: 16),
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
                      const SizedBox(width: 16),
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
                  const SizedBox(height: 32),
                  
                  // Répartition par statut avec design 3D
                  _DistributionCard3D(
                    activeProjects: dashboardProvider.activeProjects,
                    completedProjects: dashboardProvider.completedProjects,
                    blockedProjects: dashboardProvider.blockedProjects,
                    totalProjects: dashboardProvider.totalProjects,
                  ),
                ],
              ),
            ),
          );
        },
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
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey[50]!,
            ],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icône avec background en dégradé
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: gradient,
                boxShadow: [
                  BoxShadow(
                    color: gradient.colors.first.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
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
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 15),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.white,
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Répartition des Projets',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 24),
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
            const SizedBox(height: 20),
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
            const SizedBox(height: 20),
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
                    color: gradient.colors.first.withOpacity(0.3),
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
                color: Colors.black.withOpacity(0.05),
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
                          color: gradient.colors.first.withOpacity(0.4),
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
