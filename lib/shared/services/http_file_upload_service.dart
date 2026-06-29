import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HttpFileUploadService {
  // Your custom server URL
  static const String baseUrl = 'http://172.18.100.173:8087';
  
  /// Upload a PDF file to the custom server
  /// Returns the URL to access the uploaded file
  static Future<String> uploadPdf(File pdfFile, String fileName) async {
    try {
      final uri = Uri.parse('$baseUrl/ABTF_PDF_Uploads_ROUTE_CARD');
      
      var request = http.MultipartRequest('POST', uri);
      
      // Add the PDF file to the request
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          pdfFile.path,
          filename: fileName,
        ),
      );
      
      // Send the request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Parse the response to get the filename
        final responseData = json.decode(response.body);
        
        // Your server returns: {"status": "success", "filename": "...", "saved_to": "..."}
        if (responseData['status'] == 'success' && responseData['filename'] != null) {
          final filename = responseData['filename'];
          // Construct the URL using your view_pdf endpoint
          String fileUrl = '$baseUrl/view_pdf/$filename';
          
          print('✅ PDF uploaded successfully: $fileUrl');
          return fileUrl;
        } else {
          throw Exception('Upload failed: Invalid response format');
        }
      } else {
        throw Exception('Upload failed with status: ${response.statusCode}, body: ${response.body}');
      }
    } catch (e) {
      print('❌ Error uploading PDF: $e');
      throw Exception('Failed to upload PDF: $e');
    }
  }
  
  /// Download a PDF file from the custom server with retry logic
  /// Returns the local file path
  static Future<File> downloadPdf(String fileUrl, String localPath) async {
    const maxRetries = 3;
    
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        print('🔗 Download attempt $attempt/$maxRetries: $fileUrl');
        
        // Use simple GET request instead of streaming to avoid connection issues
        final response = await http.get(
          Uri.parse(fileUrl),
        ).timeout(
          const Duration(seconds: 120), // Increased timeout
        );
        
        if (response.statusCode == 200) {
          final bytes = response.bodyBytes;
          print('📦 Downloaded ${bytes.length} bytes');
          
          // Write to file
          final file = File(localPath);
          await file.writeAsBytes(bytes);
          
          print('✅ PDF saved successfully to: $localPath');
          return file;
        } else {
          throw Exception('HTTP ${response.statusCode}: ${response.body}');
        }
      } catch (e) {
        print('❌ Attempt $attempt failed: $e');
        
        if (attempt == maxRetries) {
          throw Exception('Download failed after $maxRetries attempts: $e');
        }
        
        // Wait before retry with exponential backoff
        await Future.delayed(Duration(seconds: attempt * 2));
      }
    }
    
    throw Exception('Download failed');
  }
  
  /// Check if a file exists on the server
  static Future<bool> fileExists(String fileUrl) async {
    try {
      final response = await http.head(Uri.parse(fileUrl));
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Error checking file existence: $e');
      return false;
    }
  }
  
  /// Get the full URL for a file
  static String getFileUrl(String fileName) {
    return '$baseUrl/ABTF_PDF_Uploads_ROUTE_CARD/$fileName';
  }
  
  /// List all PDF files on the server
  static Future<List<String>> listPdfs() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/list_pdfs'));
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final pdfFiles = List<String>.from(responseData['pdf_files'] ?? []);
        return pdfFiles;
      } else {
        throw Exception('Failed to list PDFs: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error listing PDFs: $e');
      throw Exception('Failed to list PDFs: $e');
    }
  }
  
  /// Update an existing PDF file on the server with retry logic
  /// Returns the URL to access the updated file
  static Future<String> updatePdf(File pdfFile, String fileName) async {
    const maxRetries = 3;
    
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        print('☁️ Upload attempt $attempt/$maxRetries...');
        
        final uri = Uri.parse('$baseUrl/update_pdf/$fileName');
        final request = http.MultipartRequest('PUT', uri);
        
        // Add the PDF file to the request
        request.files.add(
          await http.MultipartFile.fromPath(
            'file',
            pdfFile.path,
            filename: fileName,
          ),
        );
        
        // Send the request with timeout
        final streamedResponse = await request.send().timeout(
          const Duration(seconds: 120), // 2 minute timeout
        );
        
        final response = await http.Response.fromStream(streamedResponse);
        
        if (response.statusCode == 200 || response.statusCode == 201) {
          // Parse the response
          final responseData = json.decode(response.body);
          
          if (responseData['status'] == 'success') {
            final filename = responseData['filename'];
            String fileUrl = '$baseUrl/view_pdf/$filename';
            
            print('✅ PDF updated successfully: $fileUrl');
            return fileUrl;
          } else {
            throw Exception('Update failed: Invalid response format');
          }
        } else {
          throw Exception('HTTP ${response.statusCode}: ${response.body}');
        }
      } catch (e) {
        print('❌ Upload attempt $attempt failed: $e');
        
        if (attempt == maxRetries) {
          throw Exception('Failed to update PDF after $maxRetries attempts: $e');
        }
        
        // Wait before retry
        await Future.delayed(Duration(seconds: attempt * 3));
      }
    }
    
    throw Exception('Failed to update PDF');
  }
}
