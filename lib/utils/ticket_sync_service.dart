import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'connectivity_service.dart';
import 'ticket_storage_service.dart';

class TicketSyncService {
  // Sync all pending tickets when internet connection is available
  static Future<void> syncPendingTickets(BuildContext context) async {
    // Check if there's internet connectivity
    bool isConnected = await ConnectivityService.isConnected();
    
    if (!isConnected) {
      // If still offline, don't attempt to sync
      return;
    }
    
    // Get all pending tickets
    List<Map<String, dynamic>> pendingTickets = await TicketStorageService.getPendingTickets();
    
    if (pendingTickets.isEmpty) {
      // No pending tickets to sync
      return;
    }
    
    // Try to sync each pending ticket
    for (var ticketData in pendingTickets) {
      try {
        String requisitionNumber = ticketData['Requisition Number'];
        
        // Upload ticket to Firestore
        await FirebaseFirestore.instance
            .collection('Tickets')
            .doc(requisitionNumber)
            .set(ticketData, SetOptions(merge: true));
        
        // If successful, remove from pending list
        await TicketStorageService.removePendingTicket(requisitionNumber);
        
        // Show success notification
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Offline ticket #$requisitionNumber synced successfully!"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } catch (e) {
        // If there's an error, keep the ticket in pending list
        print("Error syncing ticket: $e");
      }
    }
  }
}
