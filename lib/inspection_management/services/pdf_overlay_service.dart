import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:convert';
import '../models/route_card_model.dart';

class PdfOverlayService {
  /// Generates a PDF report with inspection data
  /// Creates a comprehensive inspection report with all records
  static Future<File> generatePdfWithOverlays({
    required File originalPdfFile,
    required List<PieceMark> pieceMarks,
    required String outputPath,
  }) async {
    try {
      print('📄 Generating PDF with inspection data...');
      
      // Read the original PDF bytes
      final originalBytes = await originalPdfFile.readAsBytes();
      
      // Create a new PDF document
      final pdf = pw.Document();
      
      // Load original PDF pages using printing package
      final pageImages = await Printing.raster(originalBytes);
      
      int pageIndex = 0;
      await for (final page in pageImages) {
        pageIndex++;
        
        // Find piece mark data for this page
        final pieceMark = pieceMarks.firstWhere(
          (pm) => pm.pageNumber == pageIndex,
          orElse: () => PieceMark(
            id: '',
            pageNumber: pageIndex,
            pieceMarkId: '',
            description: '',
            inspectionPoints: {},
            inspectorSignature: '',
            inspectorId: '',
            inspectionDate: DateTime.now(),
            status: 'pending',
            annotations: [],
            remarks: '',
          ),
        );
        
        // Convert raster page to PNG bytes
        final imageBytes = await page.toPng();
        final image = pw.MemoryImage(imageBytes);
        
        // Get actual page dimensions from the rasterized page
        final pageWidth = page.width.toDouble();
        final pageHeight = page.height.toDouble();
        
        // Add page with overlays
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat(pageWidth, pageHeight),
            margin: pw.EdgeInsets.zero,
            build: (pw.Context context) {
              return pw.Stack(
                children: [
                  // Original page as background (use fill to match screen coordinates)
                  pw.Positioned.fill(
                    child: pw.Image(image, fit: pw.BoxFit.fill),
                  ),
                  
                  // Add inspection points as overlays
                  ...pieceMark.inspectionPoints.entries.map((entry) {
                    final point = entry.value;
                    
                    // Use percentage-based positioning if available (NEW METHOD)
                    if (point.posXPercent != null && point.posYPercent != null) {
                      // Calculate absolute position from percentage
                      final scaledX = point.posXPercent! * pageWidth;
                      final scaledY = point.posYPercent! * pageHeight;
                      
                      print('✅ PERCENTAGE METHOD: "${point.value}" at (${(point.posXPercent! * 100).toStringAsFixed(1)}%, ${(point.posYPercent! * 100).toStringAsFixed(1)}%) -> ($scaledX, $scaledY) on PDF ($pageWidth x $pageHeight)');
                      
                      return pw.Positioned(
                        left: scaledX,
                        top: scaledY,
                        child: pw.Container(
                          padding: const pw.EdgeInsets.all(2),
                          decoration: pw.BoxDecoration(
                            color: PdfColors.white,
                          ),
                          child: pw.Text(
                            point.value,
                            style: pw.TextStyle(fontSize: point.fontSize, color: PdfColors.black, fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                      );
                    }
                    // Fallback to old pixel-based method for backwards compatibility
                    else if (point.posX != null && point.posY != null) {
                      double scaledX = point.posX!;
                      double scaledY = point.posY!;
                      
                      if (point.screenWidth != null && point.screenHeight != null) {
                        final scaleX = pageWidth / point.screenWidth!;
                        final scaleY = pageHeight / point.screenHeight!;
                        scaledX = point.posX! * scaleX;
                        scaledY = point.posY! * scaleY;
                        print('⚠️ OLD METHOD: "${point.value}" scaled to ($scaledX, $scaledY)');
                      }
                      
                      return pw.Positioned(
                        left: scaledX,
                        top: scaledY,
                        child: pw.Container(
                          padding: const pw.EdgeInsets.all(2),
                          decoration: pw.BoxDecoration(
                            color: PdfColors.white,
                          ),
                          child: pw.Text(
                            point.value,
                            style: pw.TextStyle(fontSize: point.fontSize, color: PdfColors.black, fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                      );
                    }
                    return pw.SizedBox();
                  }).toList(),
                  
                  // Add signature overlay if exists
                  if (pieceMark.inspectorSignature.isNotEmpty)
                    pw.Positioned(
                      left: pieceMark.signatureX ?? 50,
                      top: pieceMark.signatureY ?? 50,
                      child: _buildSignatureOverlay(pieceMark.inspectorSignature),
                    ),
                ],
              );
            },
          ),
        );
      }
      
      // Save the PDF
      final outputFile = File(outputPath);
      await outputFile.writeAsBytes(await pdf.save());
      
      print('✅ PDF with overlays generated: $outputPath');
      return outputFile;
    } catch (e) {
      print('❌ Error generating PDF with overlays: $e');
      rethrow;
    }
  }
  
  /// Builds a signature overlay widget
  static pw.Widget _buildSignatureOverlay(String base64Signature) {
    try {
      final signatureBytes = base64Decode(base64Signature);
      final signatureImage = pw.MemoryImage(signatureBytes);
      
      return pw.Container(
        width: 150,
        height: 75,
        child: pw.Column(
          mainAxisSize: pw.MainAxisSize.min,
          children: [
            pw.Expanded(
              child: pw.Image(signatureImage, fit: pw.BoxFit.contain),
            ),
            pw.Container(
              padding: const pw.EdgeInsets.all(2),
              decoration: pw.BoxDecoration(
                color: PdfColors.white.flatten(),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
              ),
              child: pw.Text(
                'Inspector Signature',
                style: pw.TextStyle(fontSize: 8, color: PdfColors.grey),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      print('Error building signature overlay: $e');
      return pw.Container();
    }
  }
}
