import 'dart:convert';

List<Log> logFromJsonArry(String str) =>
    List<Log>.from(json.decode(str).map((x) => Log.fromJson(x)));

class Log {
  final int id;
  final String userName;
  final String fileName;
  final String signatureCode;
  final String action;
  final String type;
  final DateTime createdAt;

  Log({
    this.id,
    this.userName,
    this.fileName,
    this.signatureCode,
    this.action,
    this.type,
    this.createdAt,
  });

  factory Log.fromJson(Map<String, dynamic> json) {
    return Log(
      id: json["id"],
      userName: json['user_name'],
      fileName: json['file_name'],
      signatureCode: json['signature_code'],
      action: json['action'],
      type: json['type'],
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json["created_at"]).toUtc(),
    );
  }
}
