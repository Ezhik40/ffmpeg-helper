import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FFmpeg Batch 180°',
      theme: ThemeData(
        primarySwatch: Colors.blue,
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
  final _inputController = TextEditingController(text: 'mp4');
  final _outputController = TextEditingController(text: 'mp4');
  
  double _yaw = 0.0;
  double _pitch = 0.0;
  double _roll = 0.0;

    String _generateScript() {
    final ext1 = _inputController.text;
    final ext2 = _outputController.text;
    
    // Выводим Yaw и Pitch с двумя знаками после запятой
    final yawVal = _yaw.toStringAsFixed(2);
    final pitchVal = _pitch.toStringAsFixed(2);
    // Крен (Roll) оставляем целым числом
    final rollVal = _roll.round().toString();

    return 'for f in *.\$ext1; do ffmpeg -i "\$f" -filter_complex "[v:0]crop=iw/2:ih:0:0,v360=input=fisheye:output=hequirect:h_fov=200:v_fov=200:yaw=0:pitch=0:roll=0[left_eye]; [v:0]crop=iw/2:ih:iw/2:0,v360=input=fisheye:output=hequirect:h_fov=200:v_fov=200:yaw=$yawVal:pitch=$pitchVal:roll=$rollVal[right_eye]; [left_eye][right_eye]hstack=inputs=2[sbs]" -map "[sbs]" -y "\${f%.\$ext1}_sbs_180.\$ext2"; done';
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _generateScript()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Скрипт скопирован в буфер обмена!')),
    );
  }

    void _launchTermux() async {
    final Uri url = Uri.parse('android-app://com.termux');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось запустить Termux. Проверьте, установлено ли приложение.')),
      );
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    _outputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('FFmpeg Batch 180°', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    decoration: const InputDecoration(labelText: 'Входное расширение', border: OutlineInputBorder()),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _outputController,
                    decoration: const InputDecoration(labelText: 'Выходное расширение', border: OutlineInputBorder()),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text('Yaw (Поворот): ${_yaw.toStringAsFixed(2)}°', style: const TextStyle(fontWeight: FontWeight.bold)),
            Slider(
              value: _yaw,
              min: -2.0,
              max: 2.0,
              onChanged: (val) => setState(() => _yaw = val),
            ),
            Text('Pitch (Наклон): ${_pitch.toStringAsFixed(2)}°', style: const TextStyle(fontWeight: FontWeight.bold)),
            Slider(
              value: _pitch,
              min: -2.0,
              max: 2.0,
              onChanged: (val) => setState(() => _pitch = val),
            ),
            Text('Roll (Крен): ${_roll.round()}°', style: const TextStyle(fontWeight: FontWeight.bold)),
            Slider(
              value: _roll,
              min: -90.0,
              max: 90.0,
              divisions: 180, // Оставляем шаг по 1 градусу для крена
              onChanged: (val) => setState(() => _roll = val),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Text(
                _generateScript(),
                style: const TextStyle(fontFamily: 'monospace', color: Colors.black87),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _copyToClipboard,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: const Text('Копировать', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _launchTermux,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade800, padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: const Text('В Termux', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
