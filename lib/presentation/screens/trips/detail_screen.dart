import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/models/activity_model.dart';
import '../../providers/location_provider.dart';

class DetailScreen extends ConsumerWidget {
  final String? name;
  final ActivityModel? activity;

  const DetailScreen({super.key, this.name, this.activity});

  Future<void> _launchGoogleMaps(BuildContext context, String mapsUri) async {
    if (mapsUri.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lokasi wisata belum tersedia.')),
      );
      return;
    }

    final uri = Uri.parse(mapsUri);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal membuka Google Maps.')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ??
        (isDark ? Colors.white : Colors.black);
    final subTextColor =
        Theme.of(context).textTheme.bodySmall?.color ??
        (isDark ? Colors.white70 : Colors.black54);
    final cardColor = Theme.of(context).cardColor;
    final destinationName = activity?.name.trim().isNotEmpty == true
        ? activity!.name.trim()
        : (name?.trim().isNotEmpty == true ? name!.trim() : 'Golden Pavillion');
    final destinationCategory = activity?.category.trim().isNotEmpty == true
        ? activity!.category.trim()
        : 'Hotel';
    final destinationLocation = activity?.location.trim().isNotEmpty == true
        ? activity!.location.trim()
        : 'Kyoto, Japan';
    final destinationImage = activity?.imagePath?.trim().isNotEmpty == true
        ? activity!.imagePath!.trim()
        : 'assets/images/Golden Pavillion.png';
    final destinationNotes = activity?.notes.trim().isNotEmpty == true
        ? activity!.notes.trim()
        : '';
    final detailDescription = destinationNotes.length >= 140
        ? destinationNotes
        : destinationNotes.isNotEmpty
        ? '$destinationNotes\n\nNikmati pengalaman $destinationCategory di $destinationLocation dengan ritme perjalanan yang santai namun tetap terarah. Luangkan waktu untuk mengeksplorasi area sekitar, menemukan spot foto terbaik, serta mencoba rekomendasi kuliner lokal agar kunjungan terasa lebih lengkap.\n\nUntuk hasil kunjungan yang optimal, pertimbangkan datang di jam yang lebih sepi, siapkan rencana rute antar destinasi, dan sisakan waktu untuk beristirahat sejenak. Dengan begitu, perjalanan ke $destinationName akan terasa lebih nyaman, berkesan, dan mudah dinikmati dari awal sampai akhir.'
        : 'Embark on a tranquil journey to one of Kyoto\'s iconic destinations. Explore the unique cultural atmosphere, enjoy the surrounding scenery, and plan your visit with enough time to experience each spot comfortably.\n\nNikmati pengalaman $destinationCategory di $destinationLocation dengan ritme perjalanan yang santai namun tetap terarah. Luangkan waktu untuk mengeksplorasi area sekitar, menemukan spot foto terbaik, serta mencoba rekomendasi kuliner lokal agar kunjungan terasa lebih lengkap.\n\nUntuk hasil kunjungan yang optimal, pertimbangkan datang di jam yang lebih sepi, siapkan rencana rute antar destinasi, dan sisakan waktu untuk beristirahat sejenak. Dengan begitu, perjalanan ke $destinationName akan terasa lebih nyaman, berkesan, dan mudah dinikmati dari awal sampai akhir.';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Image.asset(
                      destinationImage,
                      width: double.infinity,
                      height: 380,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: 380,
                          color: Colors.grey[300],
                          alignment: Alignment.center,
                          child: const Icon(Icons.image, size: 64),
                        );
                      },
                    ),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            destinationName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            destinationCategory,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 18,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(Icons.location_on, size: 22, color: textColor),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                destinationLocation,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person, size: 22, color: textColor),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Visitor',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: subTextColor,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '65,034',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Icon(
                              Icons.star,
                              size: 22,
                              color: Colors.orange,
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Rating',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: subTextColor,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '8.5/10',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final mapsUri = await ref.read(
                          googleMapsUriProvider((
                            destinationName: destinationName,
                            location: destinationLocation,
                            activity: activity,
                          )).future,
                        );
                        if (context.mounted) {
                          await _launchGoogleMaps(context, mapsUri);
                        }
                      },
                      icon: const Icon(Icons.map_outlined, size: 18),
                      label: const Text(
                        'Lihat di google Maps',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2F4BB9),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),

                // Detail Section
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Detail',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        detailDescription,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          color: subTextColor,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Price and Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Trip Price',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: subTextColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '¥500',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                          // 💎 Detail section ini sangat komplet. Penggunaan `SingleChildScrollView`
                          // memastikan konten aman di layar yang lebih kecil. Rapi! 📱✨
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/itinerary');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2F4BB9),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 48,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Let\'s go',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // Hotel nearest section
                      Text(
                        'Hotel nearest $destinationName',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Hotel Cards
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: isDark
                                        ? Colors.black.withOpacity(0.4)
                                        : Colors.black.withOpacity(0.08),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(12),
                                    ),
                                    child: Image.asset(
                                      'assets/images/Urban Hotel.png',
                                      height: 100,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Urban Hotel Kyoto Nijo Premium',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: textColor,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.star,
                                                  size: 14,
                                                  color: Colors.orange,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '4.1/5',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: subTextColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const Text(
                                              '¥7,500',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF2F4BB9),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: isDark
                                        ? Colors.black.withOpacity(0.4)
                                        : Colors.black.withOpacity(0.08),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(12),
                                    ),
                                    child: Image.asset(
                                      'assets/images/Roku Kyoto.png',
                                      height: 100,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Roku Kyoto resort by Hilton',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: textColor,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.star,
                                                  size: 14,
                                                  color: Colors.orange,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '4.5/5',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: subTextColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const Text(
                                              '¥131,000',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF2F4BB9),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),

                // Footer (full width, no outer margin)
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: cardColor,
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.black.withOpacity(0.4)
                            : Colors.black.withOpacity(0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 24,
                    horizontal: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        'assets/images/logo_wanderly.png',
                        height: 50,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Enjoy your trip with glorious serve from harisenin.com!',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Jl. Raya Pajajaran No.88, Kel. Tanah Sareal, Kec. Bogor\nTengah, Kota Bogor, Jawa Barat, 16167, Indonesia',
                        style: TextStyle(fontSize: 11, color: subTextColor),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '+62-891827-23293',
                        style: TextStyle(fontSize: 11, color: subTextColor),
                      ),
                      const SizedBox(height: 12),
                      Image.asset('assets/images/Sosmed.png', height: 32),
                      const SizedBox(height: 12),
                      Text(
                        '©2026 Khoiri Rizki Bani Adam, All Rights Reserved',
                        style: TextStyle(
                          fontSize: 10,
                          color: subTextColor.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Fixed Back Button
          Positioned(
            top: 50,
            left: 16,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF2F4BB9),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
