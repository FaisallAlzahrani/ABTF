import 'package:cloud_firestore/cloud_firestore.dart';

class WorkOrder {
  final String id;
  final String workOrderNumber;
  final String projectName;
  final String description;
  final String createdBy;
  final DateTime createdAt;
  final DateTime dueDate;
  final String status; // 'pending', 'in_progress', 'completed', 'rejected'
  final String routeCardUrl; // URL to the uploaded RouteCard PDF
  final List<String> assignedInspectors;
  final Map<String, dynamic> metadata; // Additional information

  WorkOrder({
    required this.id,
    required this.workOrderNumber,
    required this.projectName,
    required this.description,
    required this.createdBy,
    required this.createdAt,
    required this.dueDate,
    required this.status,
    required this.routeCardUrl,
    required this.assignedInspectors,
    this.metadata = const {},
  });

  // Create from Firestore document
  factory WorkOrder.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return WorkOrder(
      id: doc.id,
      workOrderNumber: data['workOrderNumber'] ?? '',
      projectName: data['projectName'] ?? '',
      description: data['description'] ?? '',
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      status: data['status'] ?? 'pending',
      routeCardUrl: data['routeCardUrl'] ?? '',
      assignedInspectors: List<String>.from(data['assignedInspectors'] ?? []),
      metadata: data['metadata'] ?? {},
    );
  }

  // Convert to map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'workOrderNumber': workOrderNumber,
      'projectName': projectName,
      'description': description,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'dueDate': Timestamp.fromDate(dueDate),
      'status': status,
      'routeCardUrl': routeCardUrl,
      'assignedInspectors': assignedInspectors,
      'metadata': metadata,
    };
  }

  // Create a copy with updated fields
  WorkOrder copyWith({
    String? id,
    String? workOrderNumber,
    String? projectName,
    String? description,
    String? createdBy,
    DateTime? createdAt,
    DateTime? dueDate,
    String? status,
    String? routeCardUrl,
    List<String>? assignedInspectors,
    Map<String, dynamic>? metadata,
  }) {
    return WorkOrder(
      id: id ?? this.id,
      workOrderNumber: workOrderNumber ?? this.workOrderNumber,
      projectName: projectName ?? this.projectName,
      description: description ?? this.description,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      routeCardUrl: routeCardUrl ?? this.routeCardUrl,
      assignedInspectors: assignedInspectors ?? this.assignedInspectors,
      metadata: metadata ?? this.metadata,
    );
  }
}
