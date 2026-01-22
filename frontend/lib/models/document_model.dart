import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'document_model.g.dart';

enum DocumentType {
  @JsonValue('DRIVER_LICENSE')
  driverLicense,
  @JsonValue('ID_CARD')
  idCard,
  @JsonValue('INSURANCE')
  insurance,
  @JsonValue('VEHICLE_REGISTRATION')
  vehicleRegistration,
}

enum DocumentStatus {
  @JsonValue('PENDING')
  pending,
  @JsonValue('APPROVED')
  approved,
  @JsonValue('REJECTED')
  rejected,
}

@JsonSerializable()
class DocumentModel extends Equatable {
  final String id;
  final String userId;
  @JsonKey(name: 'documentType')
  final DocumentType documentType;
  final String fileName;
  final String filePath;
  final String mimeType;
  final int fileSize;
  @JsonKey(name: 'status')
  final DocumentStatus status;
  final String? rejectionReason;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DocumentModel({
    required this.id,
    required this.userId,
    required this.documentType,
    required this.fileName,
    required this.filePath,
    required this.mimeType,
    required this.fileSize,
    required this.status,
    this.rejectionReason,
    this.reviewedBy,
    this.reviewedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) =>
      _$DocumentModelFromJson(json);

  Map<String, dynamic> toJson() => _$DocumentModelToJson(this);

  @override
  List<Object?> get props => [
        id,
        userId,
        documentType,
        fileName,
        filePath,
        mimeType,
        fileSize,
        status,
        rejectionReason,
        reviewedBy,
        reviewedAt,
        createdAt,
        updatedAt,
      ];
}
