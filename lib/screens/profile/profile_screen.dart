import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/hive_service.dart';

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
    return Scaffold(
      backgroundColor: const Color(0xFFB8E6F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                color: const Color(0xFFB8E6F5),
                padding: const EdgeInsets.only(top: 24, bottom: 32),
                child: Column(
                  children: [
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: Colors.white,
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
                    const Text(
                      'Wisatawan Indonesia',
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.w700,
                        fontSize: 22,
                        color: Colors.black87,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'wisatawan@wanderly.com',
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 14,
                        color: Colors.black.withOpacity(0.6),
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
                      color: Colors.white,
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
                        _buildStatCard('Perjalanan', '12'),
                        _buildStatCard('Destinasi', '28'),
                        _buildStatCard('Ulasan', '45'),
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
                    const Text(
                      'Aktivitas',
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildMenuOption(
                      icon: Icons.bookmark_outline,
                      title: 'Wisata Tersimpan',
                      subtitle: '12 destinasi tersimpan',
                    ),
                    const SizedBox(height: 10),
                    _buildMenuOption(
                      icon: Icons.check_circle_outline,
                      title: 'Perjalanan Selesai',
                      subtitle: '8 perjalanan terpenuhi',
                    ),
                    const SizedBox(height: 10),
                    _buildMenuOption(
                      icon: Icons.star_outline,
                      title: 'Rating & Ulasan',
                      subtitle: 'Lihat ulasan Anda',
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Preferensi',
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildMenuOption(
                      icon: Icons.settings,
                      title: 'Pengaturan',
                      subtitle: 'Kelola akun dan privasi',
                    ),
                    const SizedBox(height: 10),
                    _buildMenuOption(
                      icon: Icons.help_outline,
                      title: 'Bantuan & Dukungan',
                      subtitle: 'Hubungi tim support',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2F4BB9).withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            insetPadding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 24,
                            ),
                            titlePadding: const EdgeInsets.fromLTRB(
                              20,
                              20,
                              20,
                              8,
                            ),
                            contentPadding: const EdgeInsets.fromLTRB(
                              20,
                              0,
                              20,
                              16,
                            ),
                            actionsPadding: const EdgeInsets.fromLTRB(
                              16,
                              0,
                              16,
                              16,
                            ),
                            title: const Text(
                              'Reset Data',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            content: const Text(
                              'Ini akan menghapus semua data dan reload sample Kyoto Exploration. Lanjutkan?',
                              style: TextStyle(fontSize: 14, height: 1.4),
                            ),
                            actions: [
                              SizedBox(
                                height: 40,
                                child: TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.black54,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text('Batal'),
                                ),
                              ),
                              SizedBox(
                                height: 40,
                                child: ElevatedButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2F4BB9),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text('Reset'),
                                ),
                              ),
                            ],
                          ),
                        );

                        if (confirmed == true && mounted) {
                          try {
                            await HiveService.instance.reloadSampleData();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    '✓ Sample data berhasil di-reload (14 items)',
                                  ),
                                  backgroundColor: Colors.green,
                                  duration: Duration(seconds: 3),
                                ),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF2F4BB9),
                        side: const BorderSide(
                          color: Color(0xFF2F4BB9),
                          width: 2,
                        ),
                        backgroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.refresh, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Reload Sample Data',
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
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE74C3C).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Logout berhasil'),
                            duration: Duration(seconds: 2),
                          ),
                        );
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
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF2F4BB9),
          unselectedItemColor: Colors.black45,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          elevation: 0,
          backgroundColor: Colors.transparent,
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

  Widget _buildStatCard(String label, String count) {
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
              color: Colors.black.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuOption({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
                  style: const TextStyle(
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 12,
                    color: Colors.black.withOpacity(0.55),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 18,
            color: Colors.black.withOpacity(0.35),
          ),
        ],
      ),
    );
  }
}
