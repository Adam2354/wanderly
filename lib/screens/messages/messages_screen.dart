import 'package:flutter/material.dart';

import '../trips/detail_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  int _selectedIndex = 2;

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
        break;
      case 3:
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }

  final List<Map<String, dynamic>> messages = [
    {
      'name': 'Agen Wisata Kyoto',
      'lastMessage': 'Paket tour spesial bulan ini tersedia!',
      'time': '10:30',
      'unread': true,
      'avatar': Icons.location_on,
    },
    {
      'name': 'Tim Dukungan Wanderly',
      'lastMessage': 'Terima kasih telah menggunakan Wanderly',
      'time': 'Kemarin',
      'unread': false,
      'avatar': Icons.support_agent,
    },
    {
      'name': 'Rekomendasi Destinasi',
      'lastMessage': 'Anda mungkin tertarik dengan destinasi baru',
      'time': '2 hari lalu',
      'unread': false,
      'avatar': Icons.favorite,
    },
    {
      'name': 'Notifikasi Penawaran',
      'lastMessage': 'Diskon khusus 40% untuk pemesanan hari ini',
      'time': '3 hari lalu',
      'unread': false,
      'avatar': Icons.local_offer,
    },
  ];

  void _openMessage(String name) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DetailScreen(name: name)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ??
        (isDark ? Colors.white : Colors.black);
    final subTextColor =
        Theme.of(context).textTheme.bodySmall?.color ??
        (isDark ? Colors.white70 : Colors.black54);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        title: Text(
          'Pesan',
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: textColor,
          ),
        ),
        centerTitle: false,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final message = messages[index];
          return GestureDetector(
            onTap: () => _openMessage(message['name']),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message['unread']
                    ? Colors.blue.withOpacity(isDark ? 0.12 : 0.05)
                    : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: message['unread']
                    ? Border.all(color: Colors.blue.withOpacity(0.2))
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.25 : 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2F4BB9).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(
                      message['avatar'],
                      color: const Color(0xFF2F4BB9),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              message['name'],
                              style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontWeight: message['unread']
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                fontSize: 14,
                                color: textColor,
                              ),
                            ),
                            Text(
                              message['time'],
                              style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 12,
                                color: subTextColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          message['lastMessage'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 12,
                            color: subTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (message['unread'])
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2F4BB9),
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
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
}
