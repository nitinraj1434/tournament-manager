class ConfigModel {
  final String upiId;
  final String qrImageUrl;

  ConfigModel({required this.upiId, required this.qrImageUrl});

  factory ConfigModel.fromMap(Map<String, dynamic> data) {
    return ConfigModel(
      upiId: data['upiId'] ?? '',
      qrImageUrl: data['qrImageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'upiId': upiId, 'qrImageUrl': qrImageUrl};
  }
}
