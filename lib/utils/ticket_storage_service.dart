import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TicketStorageService {
  static const String _pendingTicketsKey = 'pending_tickets';

  // Save a ticket to local storage when offline
  static Future<void> saveOfflineTicket(Map<String, dynamic> ticketData) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Get existing pending tickets or create an empty list
    List<String> pendingTickets = prefs.getStringList(_pendingTicketsKey) ?? [];
    
    // Convert ticket data to JSON string and add to the list
    pendingTickets.add(jsonEncode(ticketData));
    
    // Save the updated list back to shared preferences
    await prefs.setStringList(_pendingTicketsKey, pendingTickets);
  }

  // Get all pending tickets that need to be synced
  static Future<List<Map<String, dynamic>>> getPendingTickets() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Get the list of pending tickets
    List<String> pendingTickets = prefs.getStringList(_pendingTicketsKey) ?? [];
    
    // Convert JSON strings back to maps
    return pendingTickets.map<Map<String, dynamic>>((ticketString) {
      return Map<String, dynamic>.from(jsonDecode(ticketString));
    }).toList();
  }

  // Remove a ticket from pending list after it has been successfully synced
  static Future<void> removePendingTicket(String requisitionNumber) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Get existing pending tickets
    List<String> pendingTickets = prefs.getStringList(_pendingTicketsKey) ?? [];
    
    // Find and remove the ticket with the matching requisition number
    pendingTickets.removeWhere((ticketString) {
      Map<String, dynamic> ticket = Map<String, dynamic>.from(jsonDecode(ticketString));
      return ticket['Requisition Number'] == requisitionNumber;
    });
    
    // Save the updated list back to shared preferences
    await prefs.setStringList(_pendingTicketsKey, pendingTickets);
  }

  // Check if there are any pending tickets
  static Future<bool> hasPendingTickets() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> pendingTickets = prefs.getStringList(_pendingTicketsKey) ?? [];
    return pendingTickets.isNotEmpty;
  }
}
