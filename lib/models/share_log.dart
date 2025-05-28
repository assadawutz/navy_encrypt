import 'dart:convert';

List<ShareLog> shareLogFromJsonArry(String str) =>
    List<ShareLog>.from(json.decode(str).map((x) => ShareLog.fromJson(x)));

class ShareLog {
  final int id;
  final String sendName;
  final String sendEmail;
  final String receiveName;
  final String receiveEmail;
  final String fileName;
  final String signatureCode;
  final DateTime createdAt;

  ShareLog({
    this.id,
    this.sendName,
    this.sendEmail,
    this.receiveName,
    this.receiveEmail,
    this.fileName,
    this.signatureCode,
    this.createdAt,
  });

  factory ShareLog.fromJson(Map<String, dynamic> json) {
    return ShareLog(
      id: json["id"],
      sendName: json['send_name'],
      sendEmail: json['send_email'],
      receiveName: json['receive_name'],
      receiveEmail: json['receive_email'],
      fileName: json['file_name'],
      signatureCode: json['signature_code'],
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json["created_at"]),
    );
  }
}
