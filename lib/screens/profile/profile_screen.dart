import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/theme_provider.dart';
import '../../data/providers/auth_provider.dart';
import '../../data/providers/trip_provider.dart';
import '../../data/providers/activity_provider.dart';
import '../trips/my_trips_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  int _selectedIndex = 3;

  void _onNavbarTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        break;
      case 1:
        Navigator.pushNamed(context, '/search');
        break;
      case 2:
        Navigator.pushNamed(context, '/messages');
        break;
      case 3:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final tripStats = ref.watch(tripStatsProvider);
    final completedTripCount = tripStats['completed'] ?? 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final email = user?.email ?? 'wisatawan@wanderly.com';
    final fallbackName = email.contains('@')
        ? email.split('@').first
        : 'Wisatawan Indonesia';
    final displayName = (user?.displayName?.trim().isNotEmpty ?? false)
        ? user!.displayName!.trim()
        : fallbackName;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                padding: const EdgeInsets.only(top: 24, bottom: 32),
                child: Column(
                  children: [
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF2F4BB9).withOpacity(0.3),
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 60,
                        color: Color(0xFF2F4BB9),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      displayName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.w700,
                        fontSize: 22,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      email,
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 14,
                        color:
                            Theme.of(context).textTheme.bodySmall?.color ??
                            Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Wrap(
                      alignment: WrapAlignment.spaceEvenly,
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _buildStatCard(context, 'Perjalanan', '12'),
                        _buildStatCard(context, 'Destinasi', '28'),
                        _buildStatCard(context, 'Ulasan', '45'),
                      ],
                    ),
                  ),
                ),
              ),
              // Account Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Aktivitas',
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color:
                            Theme.of(context).textTheme.titleMedium?.color ??
                            (isDark ? Colors.white : Colors.black87),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildMenuOption(
                      context,
                      icon: Icons.bookmark_outline,
                      title: 'Wisata Tersimpan',
                      subtitle: '12 destinasi tersimpan',
                      onTap: () {
                        Navigator.pushNamed(context, '/activities');
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildMenuOption(
                      context,
                      icon: Icons.check_circle_outline,
                      title: 'Perjalanan Selesai',
                      subtitle: '$completedTripCount perjalanan terpenuhi',
                      onTap: () {
                        ref.read(tripFilterStatusProvider.notifier).state =
                            TripFilterStatus.completed;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MyTripsScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildMenuOption(
                      context,
                      icon: Icons.star_outline,
                      title: 'Rating & Ulasan',
                      subtitle: 'Lihat ulasan Anda',
                      onTap: () {
                        ref.read(activityFilterProvider.notifier).state =
                            ActivityFilter.completed;
                        Navigator.pushNamed(context, '/activities');
                      },
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Preferensi',
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color:
                            Theme.of(context).textTheme.titleMedium?.color ??
                            (isDark ? Colors.white : Colors.black87),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Dark Mode Toggle
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: SwitchListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        secondary: Icon(
                          ref.watch(themeModeProvider) == ThemeMode.dark
                              ? Icons.dark_mode
                              : Icons.light_mode,
                          color: const Color(0xFF2F4BB9),
                        ),
                        title: const Text(
                          'Dark Mode',
                          style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        subtitle: Text(
                          ref.watch(themeModeProvider) == ThemeMode.dark
                              ? 'Tema gelap aktif'
                              : 'Tema terang aktif',
                          style: const TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 12,
                          ),
                        ),
                        value: ref.watch(themeModeProvider) == ThemeMode.dark,
                        onChanged: (value) {
                          ref.read(themeModeProvider.notifier).toggleTheme();
                        },
                        activeThumbColor: const Color(0xFF2F4BB9),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildMenuOption(
                      context,
                      icon: Icons.settings,
                      title: 'Pengaturan',
                      subtitle: 'Kelola akun dan privasi',
                    ),
                    const SizedBox(height: 10),
                    _buildMenuOption(
                      context,
                      icon: Icons.help_outline,
                      title: 'Bantuan & Dukungan',
                      subtitle: 'Hubungi tim support',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.black.withOpacity(0.45)
                            : const Color(0xFFE74C3C).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        // Logout confirmation dialog
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            title: const Text(
                              'Logout',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            content: const Text(
                              'Apakah Anda yakin ingin keluar?',
                              style: TextStyle(fontSize: 14, height: 1.4),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Batal'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFE74C3C),
                                ),
                                child: const Text('Logout'),
                              ),
                            ],
                          ),
                        );

                        if (confirmed == true && mounted) {
                          // Logout from Firebase
                          await ref
                              .read(authNotifierProvider.notifier)
                              .signOut();

                          if (mounted) {
                            // Navigate to login
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              '/login',
                              (route) => false,
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE74C3C),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Logout',
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.4)
                  : Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF2F4BB9),
          unselectedItemColor:
              Theme.of(context).iconTheme.color?.withOpacity(0.6) ??
              (isDark ? Colors.white60 : Colors.black45),
          showSelectedLabels: false,
          showUnselectedLabels: false,
          elevation: 0,
          backgroundColor: Theme.of(context).cardColor,
          currentIndex: _selectedIndex,
          onTap: _onNavbarTapped,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.send), label: ''),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: '',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String count) {
    return Container(
      constraints: const BoxConstraints(minWidth: 95),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF2F4BB9).withOpacity(0.1),
            const Color(0xFF2F4BB9).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF2F4BB9).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            count,
            style: const TextStyle(
              fontFamily: 'Urbanist',
              fontWeight: FontWeight.w800,
              fontSize: 24,
              color: Color(0xFF2F4BB9),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color:
                  Theme.of(context).textTheme.bodySmall?.color ??
                  Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    final titleColor =
        Theme.of(context).textTheme.titleMedium?.color ?? Colors.black87;
    final subtitleColor =
        Theme.of(context).textTheme.bodySmall?.color ?? Colors.black54;
    final trailingColor =
        Theme.of(context).iconTheme.color?.withOpacity(0.6) ?? Colors.black45;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF2F4BB9).withOpacity(0.15),
                      const Color(0xFF2F4BB9).withOpacity(0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFF2F4BB9), size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 12,
                        color: subtitleColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 18, color: trailingColor),
            ],
          ),
        ),
      ),
    );
  }
}
