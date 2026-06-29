import 'package:cloud_firestore/cloud_firestore.dart';

class PlanningWorkOrder {
  final String id;
  final String workOrderNumber;
  final String projectName;
  final String itemDescription;
  final int quantity;
  final String createdBy;
  final DateTime createdAt;
  final DateTime dueDate;
  final String status; // 'draft', 'pending', 'in_progress', 'completed', 'rejected'
  final String routeCardUrl; // URL to the uploaded RouteCard PDF
  final List<String> inspectionSheetUrls; // URLs to individual inspection sheets
  final int totalPages; // Total number of pages in the PDF
  final Map<String, dynamic> metadata; // Additional information

  PlanningWorkOrder({
    required this.id,
    required this.workOrderNumber,
    required this.projectName,
    required this.itemDescription,
    required this.quantity,
    required this.createdBy,
    required this.createdAt,
    required this.dueDate,
    required this.status,
    required this.routeCardUrl,
    required this.inspectionSheetUrls,
    required this.totalPages,
    this.metadata = const {},
  });

  // Create from Firestore document
  factory PlanningWorkOrder.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return PlanningWorkOrder(
      id: doc.id,
      workOrderNumber: data['workOrderNumber'] ?? '',
      projectName: data['projectName'] ?? '',
      itemDescription: data['itemDescription'] ?? '',
      quantity: data['quantity'] ?? 0,
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      status: data['status'] ?? 'draft',
      routeCardUrl: data['routeCardUrl'] ?? '',
      inspectionSheetUrls: List<String>.from(data['inspectionSheetUrls'] ?? []),
      totalPages: data['totalPages'] ?? 0,
      metadata: data['metadata'] ?? {},
    );
  }

  // Convert to map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'workOrderNumber': workOrderNumber,
      'projectName': projectName,
      'itemDescription': itemDescription,
      'quantity': quantity,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'dueDate': Timestamp.fromDate(dueDate),
      'status': status,
      'routeCardUrl': routeCardUrl,
      'inspectionSheetUrls': inspectionSheetUrls,
      'totalPages': totalPages,
      'metadata': metadata,
    };
  }

  // Create a copy with updated fields
  PlanningWorkOrder copyWith({
    String? id,
    String? workOrderNumber,
    String? projectName,
    String? itemDescription,
    int? quantity,
    String? createdBy,
    DateTime? createdAt,
    DateTime? dueDate,
    String? status,
    String? routeCardUrl,
    List<String>? inspectionSheetUrls,
    int? totalPages,
    Map<String, dynamic>? metadata,
  }) {
    return PlanningWorkOrder(
      id: id ?? this.id,
      workOrderNumber: workOrderNumber ?? this.workOrderNumber,
      projectName: projectName ?? this.projectName,
      itemDescription: itemDescription ?? this.itemDescription,
      quantity: quantity ?? this.quantity,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      routeCardUrl: routeCardUrl ?? this.routeCardUrl,
      inspectionSheetUrls: inspectionSheetUrls ?? this.inspectionSheetUrls,
      totalPages: totalPages ?? this.totalPages,
      metadata: metadata ?? this.metadata,
    );
  }
}
