import 'package:flutter/material.dart';
import '../../data/activity_store.dart';

class MyItineraryScreen extends StatefulWidget {
  final String? initialCategory;

  const MyItineraryScreen({super.key, this.initialCategory});

  @override
  State<MyItineraryScreen> createState() => _MyItineraryScreenState();
}

class _MyItineraryScreenState extends State<MyItineraryScreen> {
  final ActivityStore store = ActivityStore.instance;

  late String selectedCategory;

  @override
  void initState() {
    super.initState();
    selectedCategory = 'Semua';
    if (widget.initialCategory != null &&
        store.categories.contains(widget.initialCategory)) {
      selectedCategory = widget.initialCategory!;
    }
  }

  void _showActivityForm({ActivityItem? existing, int? index}) {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final locationController = TextEditingController(
      text: existing?.location ?? '',
    );
    final notesController = TextEditingController(text: existing?.notes ?? '');
    DateTime? selectedDate = existing?.date;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit Wisata',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama wisata',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(
                  labelText: 'Lokasi',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Catatan (opsional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              StatefulBuilder(
                builder: (context, setDialogState) => InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      setDialogState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Tanggal kunjungan (opsional)',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      selectedDate != null
                          ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                          : 'Pilih tanggal',
                      style: TextStyle(
                        color: selectedDate != null
                            ? Colors.black
                            : Colors.black54,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Batal'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      final name = nameController.text.trim();
                      if (name.isEmpty) return;

                      final location = locationController.text.trim();
                      final notes = notesController.text.trim();

                      setState(() {
                        if (existing != null && index != null) {
                          final itemCategory = selectedCategory == 'Semua'
                              ? store.getCategoryForItem(existing)
                              : selectedCategory;
                          store.updateItem(
                            itemCategory,
                            store.getIndexInCategory(itemCategory, existing),
                            ActivityItem(
                              name: name,
                              location: location,
                              notes: notes,
                              date: selectedDate,
                              imagePath: existing.imagePath,
                            ),
                          );
                        }
                      });
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2F4BB9),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Simpan'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _deleteItem(int index, ActivityItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Wisata'),
        content: const Text('Yakin ingin menghapus wisata ini dari itinerary?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                if (selectedCategory == 'Semua') {
                  final itemCategory = store.getCategoryForItem(item);
                  final itemIndex = store.getIndexInCategory(
                    itemCategory,
                    item,
                  );
                  store.deleteItem(itemCategory, itemIndex);
                } else {
                  store.deleteItem(selectedCategory, index);
                }
              });
              Navigator.pop(context);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = selectedCategory == 'Semua'
        ? store.allItems()
        : store.itemsFor(selectedCategory);

    return Scaffold(
      backgroundColor: const Color(0xFFDBF7FF),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, size: 24),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 44,
                        minHeight: 44,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Wisata Saya',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            // Subtitle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  Text(
                    'Kategori: $selectedCategory',
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Category Selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: DropdownButton<String>(
                  value: selectedCategory,
                  underline: const SizedBox(),
                  isExpanded: true,
                  icon: const Icon(Icons.expand_more),
                  items: [
                    const DropdownMenuItem(
                      value: 'Semua',
                      child: Text('Semua'),
                    ),
                    ...store.categories
                        .map(
                          (category) => DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          ),
                        )
                        .toList(),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      selectedCategory = value;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Items List
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox,
                            size: 64,
                            color: Colors.black.withOpacity(0.2),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Belum ada wisata di kategori ini',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final itemCategory = selectedCategory == 'Semua'
                            ? store.getCategoryForItem(item)
                            : selectedCategory;
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Image Placeholder
                                Container(
                                  height: 150,
                                  width: double.infinity,
                                  color: Colors.grey[300],
                                  child: item.imagePath != null
                                      ? Image.asset(
                                          item.imagePath!,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return Container(
                                                  color: Colors.grey[300],
                                                  child: const Icon(
                                                    Icons.image,
                                                    color: Colors.grey,
                                                  ),
                                                );
                                              },
                                        )
                                      : Container(
                                          color: Colors.grey[300],
                                          child: const Icon(
                                            Icons.image,
                                            color: Colors.grey,
                                          ),
                                        ),
                                ),

                                // Content
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Title and Category Badge
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              item.name,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF2F4BB9),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              itemCategory,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),

                                      // Date
                                      if (item.date != null)
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.calendar_today,
                                              size: 16,
                                              color: Colors.black54,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              '${item.date!.day}/${item.date!.month}/${item.date!.year}',
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ],
                                        ),
                                      if (item.date != null)
                                        const SizedBox(height: 8),

                                      // Location
                                      if (item.location.isNotEmpty)
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.location_on,
                                              size: 16,
                                              color: Colors.black54,
                                            ),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                item.location,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      if (item.location.isNotEmpty)
                                        const SizedBox(height: 8),

                                      // Notes
                                      if (item.notes.isNotEmpty)
                                        Text(
                                          item.notes,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black45,
                                            height: 1.5,
                                          ),
                                        ),
                                      if (item.notes.isNotEmpty)
                                        const SizedBox(height: 12),

                                      // Action Buttons
                                      Row(
                                        children: [
                                          Expanded(
                                            child: SizedBox(
                                              height: 40,
                                              child: ElevatedButton.icon(
                                                onPressed: () =>
                                                    _showActivityForm(
                                                      existing: item,
                                                      index: index,
                                                    ),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: const Color(
                                                    0xFF2F4BB9,
                                                  ),
                                                  foregroundColor: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                  ),
                                                ),
                                                icon: const Icon(
                                                  Icons.edit,
                                                  size: 18,
                                                ),
                                                label: const Text(
                                                  'Edit',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: SizedBox(
                                              height: 40,
                                              child: ElevatedButton.icon(
                                                onPressed: () =>
                                                    _deleteItem(index, item),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                  foregroundColor: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                  ),
                                                ),
                                                icon: const Icon(
                                                  Icons.delete,
                                                  size: 18,
                                                ),
                                                label: const Text(
                                                  'Hapus',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
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
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
