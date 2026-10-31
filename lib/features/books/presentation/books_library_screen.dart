import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

/// Китобхона: ҳар ду китоб аз файли PDF кушода мешаванд.
class BooksLibraryScreen extends StatelessWidget {
  const BooksLibraryScreen({super.key});

  Future<void> _pickAndOpen(BuildContext context, String title) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
      withData: false,
    );
    if (!context.mounted || result == null) return;
    final path = result.files.single.path;
    if (path == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Файли PDF дастрас нашуд.')),
      );
      return;
    }
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => PdfBookViewer(title: title, path: path),
    ));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Китобхона')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Китобҳои таълимӣ',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        const Text('Фарҳангшиносӣ ва Python дар як бахш.'),
        const SizedBox(height: 18),
        Card(
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.menu_book)),
            title: const Text('Фарҳангшиносӣ'),
            subtitle: const Text('PDF-ро аз телефон интихоб кунед'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _pickAndOpen(context, 'Фарҳангшиносӣ'),
          ),
        ),
        Card(
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.code)),
            title: const Text('Python Crash Course'),
            subtitle: const Text('Eric Matthes • Нашри сеюм • PDF'),
            trailing: const Icon(Icons.picture_as_pdf_outlined),
            onTap: () => _pickAndOpen(context, 'Python Crash Course'),
          ),
        ),
        const SizedBox(height: 12),
        const Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Ҳар китобро бо интихоби PDF аз хотираи телефон кушоед. '
              'Барои дохил кардани PDF ба худи APK, файли аслиро ба ҷузвдони '
              'assets-и китоб дар GitHub илова кардан лозим аст.',
            ),
          ),
        ),
      ],
    ),
  );
}

class PdfBookViewer extends StatelessWidget {
  const PdfBookViewer({super.key, required this.title, required this.path});
  final String title;
  final String path;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: PDFView(
      filePath: path,
      enableSwipe: true,
      swipeHorizontal: false,
      autoSpacing: true,
      pageFling: true,
    ),
  );
}
