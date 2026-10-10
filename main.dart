import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:battery_plus/battery_plus.dart';

void main() {
  runApp(const FoxDiaryApp());
}

const orange = Color(0xFFFF8A24);
const purple = Color(0xFF9B7BFF);
const background = Color(0xFF101114);
const panel = Color(0xFF1B1D22);

class FoxDiaryApp extends StatelessWidget {
  const FoxDiaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'دفتر خاطرات روباهی',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: orange,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String time = '';
  int batteryLevel = -1;
  String batteryStatus = 'در حال بررسی';
  final Battery battery = Battery();

  @override
  void initState() {
    super.initState();
    updateTime();
    loadBattery();
  }

  void updateTime() {
    final now = DateTime.now();
    setState(() {
      time =
          '${now.hour.toString().padLeft(2, '0')}:'
          '${now.minute.toString().padLeft(2, '0')}';
    });
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) updateTime();
    });
  }

  Future<void> loadBattery() async {
    try {
      final level = await battery.batteryLevel;
      final state = await battery.batteryState;
      if (!mounted) return;
      setState(() {
        batteryLevel = level;
        batteryStatus = state == BatteryState.charging
            ? 'در حال شارژ'
            : state == BatteryState.full
                ? 'باتری پر است'
                : 'در حال استفاده';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => batteryStatus = 'نامشخص');
    }
  }

  void openPage(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    final date = DateTime.now();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(22),
          children: [
            const SizedBox(height: 12),
            const Icon(Icons.pets, color: orange, size: 58),
            const SizedBox(height: 8),
            const Text(
              'FOX & BUNNY',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: orange,
                fontSize: 26,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const Text(
              'دفتر خاطرات تو',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: panel,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: orange.withValues(alpha: 0.5)),
              ),
              child: Column(
                children: [
                  Text(
                    time,
                    style: const TextStyle(
                      color: orange,
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${date.year}/${date.month}/${date.day}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.battery_std, color: purple),
                      const SizedBox(width: 8),
                      Text(
                        batteryLevel < 0
                            ? 'باتری: $batteryStatus'
                            : 'باتری: $batteryLevel٪ • $batteryStatus',
                      ),
                      IconButton(
                        onPressed: loadBattery,
                        icon: const Icon(Icons.refresh, color: orange),
                        tooltip: 'به‌روزرسانی باتری',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),
            const Text(
              'امروز چطور گذشت؟ 🦊',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            MenuButton(
              icon: Icons.menu_book,
              label: 'دفتر خاطرات',
              color: orange,
              onTap: () => openPage(const DiaryPage()),
            ),
            const SizedBox(height: 12),
            MenuButton(
              icon: Icons.build_circle_outlined,
              label: 'ابزارهای گوشی',
              color: purple,
              onTap: () => openPage(const ToolsPage()),
            ),
            const SizedBox(height: 12),
            MenuButton(
              icon: Icons.favorite_border,
              label: 'درباره برنامه',
              color: orange,
              onTap: () => showAboutDialog(
                context: context,
                applicationName: 'Fox & Bunny Diary',
                applicationVersion: '1.0.0',
                children: const [
                  Text('یک دفتر خاطرات ساده با تم روباهی 🦊'),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'خاطره‌های کوچک، لحظه‌های قشنگ ❤️',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }
}

class MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const MenuButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 66,
      child: FilledButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 25),
        label: Text(
          label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: panel,
          foregroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: color.withValues(alpha: 0.6)),
          ),
        ),
      ),
    );
  }
}

class DiaryPage extends StatefulWidget {
  const DiaryPage({super.key});

  @override
  State<DiaryPage> createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {
  List<String> entries = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadEntries();
  }

  Future<void> loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      entries = prefs.getStringList('diary_entries') ?? [];
      loading = false;
    });
  }

  Future<void> saveEntries() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('diary_entries', entries);
  }

  Future<void> addEntry() async {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: panel,
        title: const Text('خاطره جدید 🦊'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'عنوان خاطره',
                  hintText: 'مثلاً یک روز قشنگ',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: bodyController,
                minLines: 3,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'خاطره‌ات رو بنویس',
                  alignLabelWithHint: true,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('بی‌خیال'),
          ),
          FilledButton(
            onPressed: () {
              if (bodyController.text.trim().isEmpty) return;
              final title = titleController.text.trim().isEmpty
                  ? 'خاطره بدون عنوان'
                  : titleController.text.trim();
              final now = DateTime.now();
              final stamp =
                  '${now.year}/${now.month}/${now.day} '
                  '${now.hour.toString().padLeft(2, '0')}:'
                  '${now.minute.toString().padLeft(2, '0')}';
              final text = '$title\n$stamp\n${bodyController.text.trim()}';
              Navigator.pop(dialogContext, text);
            },
            child: const Text('ذخیره خاطره'),
          ),
        ],
      ),
    );

    titleController.dispose();
    bodyController.dispose();

    if (result != null) {
      setState(() => entries.insert(0, result));
      await saveEntries();
    }
  }

  Future<void> deleteEntry(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف خاطره؟'),
        content: const Text('این خاطره از برنامه حذف می‌شود.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('نه'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('بله، حذف کن'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => entries.removeAt(index));
      await saveEntries();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('دفتر خاطرات'),
        backgroundColor: panel,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: addEntry,
        backgroundColor: orange,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: const Text('خاطره جدید'),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : entries.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(28),
                    child: Text(
                      'هنوز خاطره‌ای ننوشتی ❤️\n'
                      'روی «خاطره جدید» بزن و اولین خاطره‌ات رو ثبت کن.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, height: 1.8),
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final parts = entries[index].split('\n');
                    return Card(
                      color: panel,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const Icon(Icons.favorite, color: orange),
                        title: Text(parts.first),
                        subtitle: Text(
                          parts.skip(1).join('\n'),
                          maxLines: 5,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: IconButton(
                          tooltip: 'حذف خاطره',
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.redAccent,
                          ),
                          onPressed: () => deleteEntry(index),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

class ToolsPage extends StatelessWidget {
  const ToolsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ابزارهای گوشی'),
        backgroundColor: panel,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          ToolCard(
            icon: Icons.schedule,
            title: 'ساعت',
            description: 'ساعت و تاریخ در صفحه اصلی نمایش داده می‌شود.',
          ),
          ToolCard(
            icon: Icons.battery_std,
            title: 'باتری',
            description: 'درصد باتری و وضعیت شارژ در صفحه اصلی دیده می‌شود.',
          ),
          ToolCard(
            icon: Icons.phone_android,
            title: 'اطلاعات گوشی',
            description: 'این بخش در نسخه بعدی با اطلاعات دستگاه تکمیل می‌شود.',
          ),
          ToolCard(
            icon: Icons.flashlight_on,
            title: 'چراغ‌قوه',
            description: 'این ابزار در نسخه بعدی اضافه می‌شود.',
          ),
        ],
      ),
    );
  }
}

class ToolCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const ToolCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: panel,
      margin: const EdgeInsets.only(bottom: 14),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Icon(icon, color: orange, size: 32),
        title: Text(title, style: const TextStyle(fontSize: 18)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(description),
        ),
      ),
    );
  }
}