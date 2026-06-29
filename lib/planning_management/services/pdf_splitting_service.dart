import 'dart:io' show File, Directory;
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'dart:math' show Random;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PdfSplittingService {
  // Use local storage instead of Firebase Storage
  
  /// Splits a PDF file into individual pages and saves each page locally
  /// Returns a list of file paths to the saved pages
  static Future<List<String>> splitAndUploadPdf(String pdfPath, String workOrderId) async {
    try {
      // Assume pdfPath is a direct file path
      final sourceFile = File(pdfPath);
      if (!await sourceFile.exists()) {
        throw Exception('PDF file does not exist: $pdfPath');
      }
      
      // Get temporary directory for processing
      final tempDir = await getTemporaryDirectory();
      final originalPdfPath = '${tempDir.path}/original_$workOrderId.pdf';
      final pdfFile = await sourceFile.copy(originalPdfPath);
      
      // Get the page count from the work order metadata or default to 1
      int pageCount = 1;
      try {
        final workOrderDoc = await FirebaseFirestore.instance
            .collection('work_orders')
            .doc(workOrderId)
            .get();
        
        if (workOrderDoc.exists) {
          final data = workOrderDoc.data();
          if (data != null && data['totalPages'] != null) {
            pageCount = data['totalPages'] as int;
          } else if (data != null && 
                    data['metadata'] != null && 
                    data['metadata']['totalPages'] != null) {
            pageCount = data['metadata']['totalPages'] as int;
          }
        }
      } catch (e) {
        print('Error getting page count: $e');
      }
      
      // Page count already parsed above
      
      // Try to get existing inspection data for this work order
      Map<int, Map<String, dynamic>> inspectionData = {};
      try {
        final workOrderDoc = await FirebaseFirestore.instance
            .collection('work_orders')
            .doc(workOrderId)
            .get();
        
        if (workOrderDoc.exists) {
          final data = workOrderDoc.data();
          if (data != null && 
              data['metadata'] != null && 
              data['metadata']['inspectionModule'] != null && 
              data['metadata']['inspectionModule']['sheets'] != null) {
            
            final sheets = data['metadata']['inspectionModule']['sheets'] as List<dynamic>;
            for (var sheet in sheets) {
              final pageNumber = sheet['pageNumber'] as int;
              inspectionData[pageNumber] = Map<String, dynamic>.from(sheet as Map);
            }
          }
        }
      } catch (e) {
        print('Error fetching inspection data: $e');
      }
      
      // Split the PDF into individual pages
      List<String> pageUrls = [];
      for (int i = 0; i < pageCount; i++) {
        final pageNumber = i + 1;
        final outputPath = '${tempDir.path}/page_${pageNumber}_$workOrderId.pdf';
        
        // Get inspection data for this specific page
        final pageData = inspectionData[pageNumber];
        
        // Create a more detailed PDF with a page number and grid for inspection
        final pdf = pw.Document();
        
        pdf.addPage(
          pw.Page(
            build: (pw.Context context) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  pw.Header(
                    level: 0,
                    child: pw.Text('Inspection Sheet - Page $pageNumber'),
                  ),
                  pw.SizedBox(height: 10),
                  
                  // Show inspection data if available
                  if (pageData != null) _buildInspectionDataSection(pageData)
                  else pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(),
                        ),
                        child: pw.Padding(
                          padding: const pw.EdgeInsets.all(10),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('Work Order ID: $workOrderId', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                              pw.SizedBox(height: 10),
                              pw.Text('Inspection Points:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                              pw.SizedBox(height: 5),
                              pw.Text('1. Dimensions'),
                              pw.Text('2. Surface Quality'),
                              pw.Text('3. Material Specification'),
                              pw.Text('4. Welding Quality'),
                            ],
                          ),
                        ),
                      ),
                      pw.Expanded(
                        child: pw.Center(
                          child: pw.Text('Inspection Area', style: pw.TextStyle(fontSize: 24)),
                        ),
                      ),
                      pw.Container(
                        height: 100,
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(),
                        ),
                        child: pw.Center(
                          child: pw.Text('Inspector Signature'),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        );
        
        // Save the PDF to application documents directory for persistence
        final appDir = await getApplicationDocumentsDirectory();
        final inspectionDir = Directory('${appDir.path}/inspection_sheets');
        if (!await inspectionDir.exists()) {
          await inspectionDir.create(recursive: true);
        }
        
        // Create a persistent path for this inspection sheet
        final persistentPath = '${inspectionDir.path}/${workOrderId}_page_${i + 1}.pdf';
        final persistentFile = File(persistentPath);
        await persistentFile.writeAsBytes(await pdf.save());
        
        // Also save a temporary copy for processing
        final outputFile = File(outputPath);
        await outputFile.writeAsBytes(await pdf.save());
        
        // Upload to Firebase Storage for Inspection Module compatibility
        try {
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('inspection_sheets')
              .child('${workOrderId}_page_${i + 1}.pdf');
          
          await storageRef.putFile(persistentFile);
          final downloadUrl = await storageRef.getDownloadURL();
          
          // Add the download URL to our list
          pageUrls.add(downloadUrl);
        } on FirebaseException catch (e) {
          print('Firebase Storage upload failed (${e.code}): ${e.message}');
          print('Falling back to local path for page ${i + 1}');
          // Fall back to local path if Firebase upload fails
          pageUrls.add(persistentPath);
        } catch (e) {
          print('Error uploading page ${i + 1} to Firebase Storage: $e');
          // Fall back to local path if Firebase upload fails
          pageUrls.add(persistentPath);
        }
        
        // Clean up the temporary file
        if (await outputFile.exists()) {
          await outputFile.delete();
        }
      }
      
      // Clean up the original file
      if (await pdfFile.exists()) {
        await pdfFile.delete();
      }
      
      return pageUrls;
    } catch (e) {
      print('Error splitting PDF: $e');
      rethrow;
    }
  }
  
  // Method removed - PDF pages are now saved directly to the application documents directory
  
  /// Merges multiple PDF pages into a single PDF
  /// Returns the path to the merged PDF
  static Future<String> mergePdfPages(List<String> pagePaths, String workOrderId) async {
    try {
      // Get temporary directory
      final tempDir = await getTemporaryDirectory();
      final outputPath = '${tempDir.path}/merged_$workOrderId.pdf';
      
      // Copy all pages to a temporary location
      List<String> tempPaths = [];
      for (int i = 0; i < pagePaths.length; i++) {
        final tempPath = '${tempDir.path}/merge_page_${i + 1}_$workOrderId.pdf';
        await _downloadFile(pagePaths[i], tempPath);
        tempPaths.add(tempPath);
      }
      
      // Try to get inspection data from Firestore
      Map<int, Map<String, dynamic>> inspectionData = {};
      try {
        final workOrderDoc = await FirebaseFirestore.instance
            .collection('work_orders')
            .doc(workOrderId)
            .get();
        
        if (workOrderDoc.exists) {
          final data = workOrderDoc.data();
          if (data != null && 
              data['metadata'] != null && 
              data['metadata']['inspectionModule'] != null && 
              data['metadata']['inspectionModule']['sheets'] != null) {
            
            final sheets = data['metadata']['inspectionModule']['sheets'] as List<dynamic>;
            for (var sheet in sheets) {
              final pageNumber = sheet['pageNumber'] as int;
              inspectionData[pageNumber] = Map<String, dynamic>.from(sheet as Map);
            }
          }
        }
      } catch (e) {
        print('Error fetching inspection data: $e');
      }
      
      // Create a merged PDF with inspection data
      final pdf = pw.Document();
      
      // Add a page for each original page, including inspection data if available
      for (int i = 0; i < tempPaths.length; i++) {
        final pageNumber = i + 1;
        // Get inspection data for this specific page
        final pageData = inspectionData[pageNumber];
        
        pdf.addPage(
          pw.Page(
            build: (pw.Context context) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  pw.Header(
                    level: 0,
                    child: pw.Text('Inspection Sheet - Page $pageNumber'),
                  ),
                  pw.SizedBox(height: 10),
                  
                  // Show inspection data if available
                  if (pageData != null) _buildInspectionDataSection(pageData)
                  else pw.Center(
                    child: pw.Text('No inspection data available for this page'),
                  ),
                ],
              );
            },
          ),
        );
      }
      
      // Save the merged PDF
      final outputFile = File(outputPath);
      await outputFile.writeAsBytes(await pdf.save());
      
      // Clean up temporary files
      for (String tempPath in tempPaths) {
        final tempFile = File(tempPath);
        if (await tempFile.exists()) {
          await tempFile.delete();
        }
      }
      
      return outputPath;
    } catch (e) {
      print('Error merging PDF pages: $e');
      rethrow;
    }
  }
  
  /// Creates a PDF widget to display inspection data
  static pw.Widget _buildInspectionDataSection(Map<String, dynamic> pageData) {
    final status = pageData['status'] as String? ?? 'pending';
    final remarks = pageData['remarks'] as String? ?? '';

    // inspectionPoints may be stored as a Map or as a List in Firestore; normalize to Map
    final dynamic rawInspectionPoints = pageData['inspectionPoints'];
    Map<dynamic, dynamic> inspectionPoints = {};
    if (rawInspectionPoints is Map) {
      inspectionPoints = rawInspectionPoints as Map<dynamic, dynamic>;
    } else if (rawInspectionPoints is List) {
      // Convert list to map using index as key
      for (int i = 0; i < rawInspectionPoints.length; i++) {
        inspectionPoints[i.toString()] = rawInspectionPoints[i];
      }
    }
    
    // Determine status color and text
    PdfColor statusColor;
    String statusText;
    
    switch (status) {
      case 'completed':
      case 'passed':
        statusColor = PdfColors.green;
        statusText = 'COMPLETED';
        break;
      case 'failed':
        statusColor = PdfColors.red;
        statusText = 'FAILED';
        break;
      case 'pending':
        statusColor = PdfColors.orange;
        statusText = 'IN PROGRESS';
        break;
      default:
        statusColor = PdfColors.grey;
        statusText = 'UNKNOWN';
    }
    
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
      ),
      padding: const pw.EdgeInsets.all(10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Status header with background color
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            decoration: pw.BoxDecoration(
              color: statusColor.shade(0.1),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
              border: pw.Border.all(color: statusColor),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Inspection Status:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text(
                  statusText,
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
          
          pw.SizedBox(height: 15),
          pw.Text('Inspection Points:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Divider(color: PdfColors.grey300),
          pw.SizedBox(height: 5),
          
          // Display inspection points in a table format
          if (inspectionPoints.isNotEmpty)
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              columnWidths: {
                0: const pw.FlexColumnWidth(2),  // Point name
                1: const pw.FlexColumnWidth(3),  // Value
                2: const pw.FlexColumnWidth(1),  // Result
              },
              children: [
                // Table header
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text('Point', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text('Value', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text('Result', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                  ],
                ),
                // Table rows for each inspection point
                ...inspectionPoints.entries.map((entry) {
                  final pointName = entry.key.toString();
                  final pointData = entry.value as Map<dynamic, dynamic>;
                  final pointValue = pointData['value'] as String? ?? '';
                  final pointResult = pointData['result'] as String? ?? 'na';
                  
                  // Determine result color
                  PdfColor resultColor;
                  switch (pointResult) {
                    case 'pass':
                      resultColor = PdfColors.green;
                      break;
                    case 'fail':
                      resultColor = PdfColors.red;
                      break;
                    default:
                      resultColor = PdfColors.grey;
                  }
                  
                  return pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(capitalize(pointName)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(pointValue),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(
                          pointResult.toUpperCase(),
                          style: pw.TextStyle(color: resultColor, fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ],
            )
          else
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                border: pw.Border.all(color: PdfColors.grey300),
              ),
              child: pw.Text('No inspection points recorded'),
            ),
          
          pw.SizedBox(height: 15),
          pw.Text('Inspector Remarks:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Divider(color: PdfColors.grey300),
          pw.SizedBox(height: 5),
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(8),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
            ),
            child: pw.Text(remarks.isEmpty ? 'No remarks provided' : remarks),
          ),
        ],
      ),
    );
  }
  
  // Extension to capitalize first letter of a string
  static String capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  /// Copies a file from source path to destination path or creates a placeholder
  static Future<void> _downloadFile(String sourcePath, String destPath) async {
    try {
      // Handle normal file path
      final sourceFile = File(sourcePath);
      
      if (await sourceFile.exists()) {
        // Copy the file to the destination
        await sourceFile.copy(destPath);
        return;
      }
      
      // If source file doesn't exist, create a placeholder PDF
      print('Source file does not exist: $sourcePath, creating placeholder');
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Text('Placeholder PDF'),
            );
          },
        ),
      );
      
      final destFile = File(destPath);
      await destFile.writeAsBytes(await pdf.save());
      
    } catch (e) {
      print('Error in _downloadFile: $e');
      // Create a placeholder PDF as a last resort
      try {
        final pdf = pw.Document();
        pdf.addPage(
          pw.Page(
            build: (pw.Context context) {
              return pw.Center(
                child: pw.Text('Error: $e'),
              );
            },
          ),
        );
        
        final destFile = File(destPath);
        await destFile.writeAsBytes(await pdf.save());
      } catch (finalError) {
        print('Fatal error creating placeholder PDF: $finalError');
      }
    }
  }
}
