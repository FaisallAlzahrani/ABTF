import 'package:cloud_firestore/cloud_firestore.dart';

class RouteCard {
  final String id;
  final String workOrderId; // Reference to parent work order
  final int totalPages;
  final List<PieceMark> pieceMarks;
  final DateTime lastUpdated;
  final String status; // 'pending', 'in_progress', 'completed'
  
  RouteCard({
    required this.id,
    required this.workOrderId,
    required this.totalPages,
    required this.pieceMarks,
    required this.lastUpdated,
    required this.status,
  });

  // Create from Firestore document
  factory RouteCard.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    List<PieceMark> pieceMarks = [];
    if (data['pieceMarks'] != null) {
      pieceMarks = (data['pieceMarks'] as List).map((item) => 
        PieceMark.fromMap(item as Map<String, dynamic>)).toList();
    }
    
    return RouteCard(
      id: doc.id,
      workOrderId: data['workOrderId'] ?? '',
      totalPages: data['totalPages'] ?? 0,
      pieceMarks: pieceMarks,
      lastUpdated: (data['lastUpdated'] as Timestamp).toDate(),
      status: data['status'] ?? 'pending',
    );
  }

  // Convert to map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'workOrderId': workOrderId,
      'totalPages': totalPages,
      'pieceMarks': pieceMarks.map((pieceMark) => pieceMark.toMap()).toList(),
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'status': status,
    };
  }
}

class PieceMark {
  final String id;
  final int pageNumber;
  final String pieceMarkId; // The unique identifier for this piece
  final String description;
  final Map<String, InspectionPoint> inspectionPoints;
  final String inspectorSignature; // Base64 encoded signature
  final double? signatureX; // Signature position X
  final double? signatureY; // Signature position Y
  final String inspectorId;
  final DateTime inspectionDate;
  final String status; // 'pending', 'passed', 'failed', 'waived'
  final List<String> annotations; // List of annotation data (could be JSON strings)
  final String remarks;
  
  PieceMark({
    required this.id,
    required this.pageNumber,
    required this.pieceMarkId,
    required this.description,
    required this.inspectionPoints,
    this.inspectorSignature = '',
    this.signatureX,
    this.signatureY,
    this.inspectorId = '',
    DateTime? inspectionDate,
    this.status = 'pending',
    this.annotations = const [],
    this.remarks = '',
  }) : this.inspectionDate = inspectionDate ?? DateTime.now();

  // Create from map
  factory PieceMark.fromMap(Map<String, dynamic> data) {
    Map<String, InspectionPoint> inspectionPoints = {};
    
    if (data['inspectionPoints'] != null) {
      (data['inspectionPoints'] as Map<String, dynamic>).forEach((key, value) {
        inspectionPoints[key] = InspectionPoint.fromMap(value as Map<String, dynamic>);
      });
    }
    
    return PieceMark(
      id: data['id'] ?? '',
      pageNumber: data['pageNumber'] ?? 0,
      pieceMarkId: data['pieceMarkId'] ?? '',
      description: data['description'] ?? '',
      inspectionPoints: inspectionPoints,
      inspectorSignature: data['inspectorSignature'] ?? '',
      signatureX: data['signatureX']?.toDouble(),
      signatureY: data['signatureY']?.toDouble(),
      inspectorId: data['inspectorId'] ?? '',
      inspectionDate: data['inspectionDate'] != null 
        ? (data['inspectionDate'] as Timestamp).toDate() 
        : DateTime.now(),
      status: data['status'] ?? 'pending',
      annotations: List<String>.from(data['annotations'] ?? []),
      remarks: data['remarks'] ?? '',
    );
  }

  // Convert to map
  Map<String, dynamic> toMap() {
    Map<String, dynamic> inspectionPointsMap = {};
    inspectionPoints.forEach((key, value) {
      inspectionPointsMap[key] = value.toMap();
    });
    
    return {
      'id': id,
      'pageNumber': pageNumber,
      'pieceMarkId': pieceMarkId,
      'description': description,
      'inspectionPoints': inspectionPointsMap,
      'inspectorSignature': inspectorSignature,
      'signatureX': signatureX,
      'signatureY': signatureY,
      'inspectorId': inspectorId,
      'inspectionDate': Timestamp.fromDate(inspectionDate),
      'status': status,
      'annotations': annotations,
      'remarks': remarks,
    };
  }
}

class InspectionPoint {
  final String name;
  final String value;
  final String result;
  final String comments;
  final double? posX; // X position on the PDF (absolute pixels - legacy)
  final double? posY; // Y position on the PDF (absolute pixels - legacy)
  final double? screenWidth; // Screen widget width when tap was captured
  final double? screenHeight; // Screen widget height when tap was captured
  final double fontSize; // Font size for the text (default 12)
  
  // NEW: Percentage-based positioning (0.0 to 1.0)
  final double? posXPercent; // X as percentage of page width (0.0 = left, 1.0 = right)
  final double? posYPercent; // Y as percentage of page height (0.0 = top, 1.0 = bottom)

  InspectionPoint({
    required this.name,
    required this.value,
    required this.result,
    this.comments = '',
    this.posX,
    this.posY,
    this.screenWidth,
    this.screenHeight,
    this.fontSize = 12.0,
    this.posXPercent,
    this.posYPercent,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'value': value,
      'result': result,
      'comments': comments,
      'posX': posX,
      'posY': posY,
      'screenWidth': screenWidth,
      'screenHeight': screenHeight,
      'fontSize': fontSize,
      'posXPercent': posXPercent,
      'posYPercent': posYPercent,
    };
  }
  
  factory InspectionPoint.fromMap(Map<String, dynamic> map) {
    return InspectionPoint(
      name: map['name'] ?? '',
      value: map['value'] ?? '',
      result: map['result'] ?? '',
      comments: map['comments'] ?? '',
      posX: map['posX']?.toDouble(),
      posY: map['posY']?.toDouble(),
      screenWidth: map['screenWidth']?.toDouble(),
      screenHeight: map['screenHeight']?.toDouble(),
      fontSize: map['fontSize']?.toDouble() ?? 12.0,
      posXPercent: map['posXPercent']?.toDouble(),
      posYPercent: map['posYPercent']?.toDouble(),
    );
  }
}
