import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

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
        appBar: AppBar(title: const Text("BOOK'S")),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Маҷмӯи китобҳо',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text('Китобҳои барномасозӣ ва омӯзишӣ.'),
            const SizedBox(height: 18),
            Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.code_rounded)),
                title: const Text('Python Crash Course'),
                subtitle: const Text('Eric Matthes • 3rd Edition • PDF'),
                trailing: const Icon(Icons.menu_book_rounded),
                onTap: () => _pickAndOpen(context, 'Python Crash Course'),
              ),
            ),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Барои хондан тугмаи китобро пахш кунед ва PDF-и '
                  'Python Crash Course-ро аз телефони худ интихоб намоед. '
                  'Нусхаи PDF ба таври худкор ба APK дохил карда нашудааст.',
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
