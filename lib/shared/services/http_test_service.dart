import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Test service to verify HTTP server endpoints are working
class HttpTestService {
  static const String baseUrl = 'http://172.18.100.173:8087';
  
  /// Test all endpoints and print results
  static Future<void> testAllEndpoints() async {
    print('\n========================================');
    print('🧪 Testing HTTP Server Endpoints');
    print('========================================\n');
    
    // Test 1: Server is reachable
    await _testServerReachable();
    
    // Test 2: List PDFs endpoint
    await _testListPdfs();
    
    print('\n========================================');
    print('✅ All Tests Complete');
    print('========================================\n');
  }
  
  /// Test if server is reachable
  static Future<void> _testServerReachable() async {
    try {
      print('📡 Test 1: Checking if server is reachable...');
      final response = await http.get(Uri.parse('$baseUrl/list_pdfs')).timeout(
        const Duration(seconds: 5),
      );
      
      if (response.statusCode == 200) {
        print('✅ Server is reachable!');
        print('   Status: ${response.statusCode}');
      } else {
        print('⚠️  Server responded but with status: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Server is NOT reachable: $e');
      print('   Make sure your Flask server is running at $baseUrl');
    }
    print('');
  }
  
  /// Test list PDFs endpoint
  static Future<void> _testListPdfs() async {
    try {
      print('📋 Test 2: Testing /list_pdfs endpoint...');
      final response = await http.get(Uri.parse('$baseUrl/list_pdfs'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final pdfFiles = data['pdf_files'] as List<dynamic>;
        print('✅ List PDFs endpoint working!');
        print('   Found ${pdfFiles.length} PDF files on server:');
        if (pdfFiles.isEmpty) {
          print('   (No files yet - upload some PDFs to test)');
        } else {
          for (var file in pdfFiles.take(5)) {
            print('   - $file');
          }
          if (pdfFiles.length > 5) {
            print('   ... and ${pdfFiles.length - 5} more');
          }
        }
      } else {
        print('❌ List PDFs failed with status: ${response.statusCode}');
        print('   Response: ${response.body}');
      }
    } catch (e) {
      print('❌ List PDFs test failed: $e');
    }
    print('');
  }
  
  /// Test upload endpoint with a sample PDF
  static Future<void> testUpload(File pdfFile, String fileName) async {
    try {
      print('\n📤 Testing PDF Upload...');
      print('   File: $fileName');
      
      final uri = Uri.parse('$baseUrl/ABTF_PDF_Uploads_ROUTE_CARD');
      var request = http.MultipartRequest('POST', uri);
      
      request.files.add(
        await http.MultipartFile.fromPath('file', pdfFile.path, filename: fileName),
      );
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Upload successful!');
        print('   Status: ${data['status']}');
        print('   Filename: ${data['filename']}');
        print('   Saved to: ${data['saved_to']}');
      } else {
        print('❌ Upload failed with status: ${response.statusCode}');
        print('   Response: ${response.body}');
      }
    } catch (e) {
      print('❌ Upload test failed: $e');
    }
    print('');
  }
  
  /// Test download/view endpoint
  static Future<void> testDownload(String fileName) async {
    try {
      print('\n📥 Testing PDF Download/View...');
      print('   File: $fileName');
      
      final url = '$baseUrl/view_pdf/$fileName';
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        print('✅ Download successful!');
        print('   File size: ${response.bodyBytes.length} bytes');
        print('   URL: $url');
      } else {
        print('❌ Download failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Download test failed: $e');
    }
    print('');
  }
}
