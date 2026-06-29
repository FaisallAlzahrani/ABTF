import 'dart:async';
import 'package:flutter/material.dart';
import 'connectivity_service.dart';
import 'ticket_storage_service.dart';
import 'ticket_sync_service.dart';

class ConnectivityMonitor {
  static Timer? _connectivityTimer;
  static bool _isMonitoring = false;

  // Start periodic connectivity monitoring
  static void startMonitoring(BuildContext context) {
    if (_isMonitoring) return;
    
    _isMonitoring = true;
    
    // Check connectivity every 30 seconds
    _connectivityTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      await _checkConnectivityAndSync(context);
    });
  }

  // Stop monitoring
  static void stopMonitoring() {
    _connectivityTimer?.cancel();
    _isMonitoring = false;
  }

  // Check connectivity and sync pending tickets if online
  static Future<void> _checkConnectivityAndSync(BuildContext context) async {
    // Check if there are any pending tickets
    bool hasPendingTickets = await TicketStorageService.hasPendingTickets();
    
    if (hasPendingTickets) {
      // Check for internet connectivity
      bool isConnected = await ConnectivityService.isConnected();
      
      if (isConnected) {
        // If online, sync pending tickets
        await TicketSyncService.syncPendingTickets(context);
        
        // If no more pending tickets, stop monitoring
        bool stillHasPendingTickets = await TicketStorageService.hasPendingTickets();
        if (!stillHasPendingTickets) {
          stopMonitoring();
        }
      }
    } else {
      // If no pending tickets, stop monitoring
      stopMonitoring();
    }
  }
}
