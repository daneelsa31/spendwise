import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html; 
import 'package:intl/intl.dart';
import 'expense_service.dart';

class ExportService {
  static Future<String> exportCurrentMonth() async {
    final now = DateTime.now();
    final monthLabel = DateFormat('MMMM yyyy').format(now);
    final fmt = DateFormat('MMM dd, yyyy');

    final all = ExpenseService.getAllExpenses();
    final monthly = all.where(
      (e) => e.date.year == now.year && e.date.month == now.month
    ).toList()..sort((a, b) => a.date.compareTo(b.date));

    final buf = StringBuffer();
    buf.writeln('========================================');
    buf.writeln('         SPENDWISE EXPENSE REPORT');
    buf.writeln('         $monthLabel');
    buf.writeln('========================================');
    buf.writeln();

    double total = 0;
    for (final e in monthly) {
      buf.writeln('${fmt.format(e.date).padRight(16)} '
          '${e.category.name.padRight(14)} '
          '₱${e.amount.toStringAsFixed(2).padLeft(10)} '
          '   ${e.title}');
      total += e.amount;
    }

    buf.writeln();
    buf.writeln('----------------------------------------');
    buf.writeln('${' ' * 32}TOTAL  ₱${total.toStringAsFixed(2)}');
    buf.writeln('========================================');
    buf.writeln('Generated: ${DateFormat('yyyy-MM-dd HH:mm').format(now)}');

    // --- WEB DOWNLOAD LOGIC ---
    final content = buf.toString();
    final bytes = utf8.encode(content);
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    
    final fileName = 'spendwise_${now.year}_${now.month.toString().padLeft(2, '0')}.txt';

    // Create a virtual anchor element and "click" it to download
    html.AnchorElement(href: url)
      ..setAttribute("download", fileName)
      ..click();

    html.Url.revokeObjectUrl(url);

    return "Downloads/$fileName"; // Return a fake path for the SnackBar
  }
}