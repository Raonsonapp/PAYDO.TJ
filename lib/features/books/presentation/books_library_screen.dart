import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

/// Китобхона: Фарҳангшиносӣ ва Python дар як бахши алоҳида.
class BooksLibraryScreen extends StatelessWidget {
  const BooksLibraryScreen({super.key});

  Future<void> _openPythonPdf(BuildContext context) async {
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
      builder: (_) => PdfBookViewer(title: 'Python Crash Course', path: path),
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
        const Text('Ду китоб дар як бахш — ҳар кадомро алоҳида кушоед.'),
        const SizedBox(height: 18),
        Card(
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.menu_book)),
            title: const Text('Фарҳангшиносӣ'),
            subtitle: const Text('Китоби мавҷудаи лоиҳа'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text(
                'Барои кушодан PDF-и фарҳангшиносиро аз телефон интихоб кунед.')),
            ),
          ),
        ),
        Card(
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.code)),
            title: const Text('Python Crash Course'),
            subtitle: const Text('Eric Matthes • Нашри сеюм • PDF'),
            trailing: const Icon(Icons.picture_as_pdf_outlined),
            onTap: () => _openPythonPdf(context),
          ),
        ),
        const SizedBox(height: 12),
        const Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Барои хондани Python PDF-ро аз хотираи телефон интихоб кунед. '
              'Файлро дар GitHub низ ба books/python_crash_course/assets/ гузоред, '
              'то дар версияҳои оянда он дохили APK бошад.',
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
