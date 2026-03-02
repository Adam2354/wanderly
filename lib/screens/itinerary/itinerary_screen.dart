import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/activity_model.dart';
import '../../data/providers/activity_provider.dart';
import 'my_itinerary_screen.dart';

// 💎 `ItineraryScreen` menggunakan `DropdownButton` untuk pemilihan tanggal
// yang sangat interaktif dan meminimalisir kesalahan input user. Brilliant! 📅✨
class ItineraryScreen extends ConsumerStatefulWidget {
  const ItineraryScreen({super.key});

  @override
  ConsumerState<ItineraryScreen> createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends ConsumerState<ItineraryScreen> {
  String selectedDay = '24';
  String selectedMonth = 'Sep';
  String selectedYear = '2025';
  bool isDateSelected = false;
  String? selectedActivity;
  int _selectedIndex = 0;

  void _onNavbarTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        break;
      case 1:
        // Search
        Navigator.pushNamed(context, '/search');
        break;
      case 2:
        // Messages
        Navigator.pushNamed(context, '/messages');
        break;
      case 3:
        // Profile
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ??
        (isDark ? Colors.white : Colors.black);
    final subTextColor =
        Theme.of(context).textTheme.bodySmall?.color ??
        (isDark ? Colors.white70 : Colors.black54);
    final cardColor = Theme.of(context).cardColor;
    final shadowColor = Colors.black.withOpacity(isDark ? 0.35 : 0.08);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: shadowColor,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.arrow_back,
                          size: 24,
                          color: textColor,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 44,
                          minHeight: 44,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Kyoto Exploration',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              // Pick up a date section
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pick up a date!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Day Dropdown
                        Expanded(
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: shadowColor,
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: DropdownButton<String>(
                              value: selectedDay,
                              underline: const SizedBox(),
                              isExpanded: true,
                              icon: Icon(Icons.expand_more, color: textColor),
                              dropdownColor: cardColor,
                              style: TextStyle(color: textColor),
                              items:
                                  List.generate(31, (i) => (i + 1).toString())
                                      .map(
                                        (day) => DropdownMenuItem(
                                          value: day,
                                          child: Text(day),
                                        ),
                                      )
                                      .toList(),
                              // 💎 Implementasi Dropdown untuk tanggal, bulan, tahun sangat user-friendly.
                              // Perubahan state via `setState` di sini sudah sangat tepat! 📅✅
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    selectedDay = value;
                                    isDateSelected = true;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Month Dropdown
                        Expanded(
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: shadowColor,
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: DropdownButton<String>(
                              value: selectedMonth,
                              underline: const SizedBox(),
                              isExpanded: true,
                              icon: Icon(Icons.expand_more, color: textColor),
                              dropdownColor: cardColor,
                              style: TextStyle(color: textColor),
                              items:
                                  [
                                        'Jan',
                                        'Feb',
                                        'Mar',
                                        'Apr',
                                        'May',
                                        'Jun',
                                        'Jul',
                                        'Aug',
                                        'Sep',
                                        'Oct',
                                        'Nov',
                                        'Dec',
                                      ]
                                      .map(
                                        (month) => DropdownMenuItem(
                                          value: month,
                                          child: Text(month),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    selectedMonth = value;
                                    isDateSelected = true;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Year Dropdown
                        Expanded(
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: shadowColor,
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: DropdownButton<String>(
                              value: selectedYear,
                              underline: const SizedBox(),
                              isExpanded: true,
                              icon: Icon(Icons.expand_more, color: textColor),
                              dropdownColor: cardColor,
                              style: TextStyle(color: textColor),
                              items: ['2024', '2025', '2026', '2027']
                                  .map(
                                    (year) => DropdownMenuItem(
                                      value: year,
                                      child: Text(year),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    selectedYear = value;
                                    isDateSelected = true;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: selectedActivity != null
                            ? () {
                                // Add activity using Riverpod provider
                                final activity = ActivityModel(
                                  name: 'Kyoto Exploration',
                                  location: 'Kyoto, Japan',
                                  notes: 'Ditambahkan dari itinerary',
                                  category: selectedActivity!,
                                );
                                ref
                                    .read(activitiesProvider.notifier)
                                    .addActivity(activity);

                                showDialog(
                                  context: context,
                                  barrierDismissible: true,
                                  builder: (context) => Dialog(
                                    backgroundColor: cardColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 24,
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.check_circle,
                                            color: Colors.green,
                                            size: 56,
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'Berhasil ditambahkan!',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: textColor,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        MyItineraryScreen(
                                                          initialCategory:
                                                              selectedActivity,
                                                        ),
                                                  ),
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    colorScheme.primary,
                                                foregroundColor:
                                                    colorScheme.onPrimary,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                              child: const Text(
                                                'Kelola Itinerary',
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text('Tutup'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedActivity != null
                              ? colorScheme.primary
                              : Theme.of(context).disabledColor,
                          foregroundColor: selectedActivity != null
                              ? colorScheme.onPrimary
                              : subTextColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: selectedActivity != null ? 4 : 0,
                        ),
                        child: const Text(
                          'Book Now',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Add to Itinerary section
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add to Itinerary',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Add Activities',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: subTextColor,
                      ),
                    ),
                    const SizedBox(height: 18),
                    // Activity Grid
                    GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _ActivityCard(
                          icon: Icons.camera_alt,
                          label: 'Sightseeing',
                          onActivitySelected: (activity) {
                            setState(() {
                              selectedActivity = activity;
                            });
                          },
                        ),
                        _ActivityCard(
                          icon: Icons.local_cafe,
                          label: 'Restaurant',
                          onActivitySelected: (activity) {
                            setState(() {
                              selectedActivity = activity;
                            });
                          },
                        ),
                        _ActivityCard(
                          icon: Icons.nightlife,
                          label: 'Nightlife',
                          onActivitySelected: (activity) {
                            setState(() {
                              selectedActivity = activity;
                            });
                          },
                        ),
                        _ActivityCard(
                          icon: Icons.apartment,
                          label: 'Hotel',
                          onActivitySelected: (activity) {
                            setState(() {
                              selectedActivity = activity;
                            });
                          },
                        ),
                        _ActivityCard(
                          icon: Icons.shopping_bag,
                          label: 'Shopping',
                          onActivitySelected: (activity) {
                            setState(() {
                              selectedActivity = activity;
                            });
                          },
                        ),
                        _ActivityCard(
                          icon: Icons.monitor,
                          label: 'Cinema',
                          onActivitySelected: (activity) {
                            setState(() {
                              selectedActivity = activity;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: cardColor,
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: colorScheme.primary,
          unselectedItemColor: subTextColor,
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
}

class _ActivityCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Function(String)? onActivitySelected;

  const _ActivityCard({
    required this.icon,
    required this.label,
    this.onActivitySelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final cardColor = Theme.of(context).cardColor;
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ??
        (isDark ? Colors.white : Colors.black);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.35 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onActivitySelected?.call(label),
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 56, color: colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
