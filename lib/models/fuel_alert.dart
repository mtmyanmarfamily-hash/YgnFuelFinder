class FuelAlert {
  final String id;
  final String stationId;
  final String stationName;
  final List<String> fuelTypes;
  final bool isEnabled;
  final bool notifyAvailable;
  final bool notifyBusy;
  final bool notifyUnavailable;

  FuelAlert({
    required this.id,
    required this.stationId,
    required this.stationName,
    required this.fuelTypes,
    this.isEnabled = true,
    this.notifyAvailable = true,
    this.notifyBusy = true,
    this.notifyUnavailable = true,
  });

  // 🔥 alert.isActive ဆိုပြီး ခေါ်သုံးနေတဲ့အတွက် ထည့်ပေးရပါမယ်
  bool get isActive => isEnabled;

  Map<String, dynamic> toJson() => {
    'id': id,
    'stationId': stationId,
    'stationName': stationName,
    'fuelTypes': fuelTypes,
    'isEnabled': isEnabled,
    'notifyAvailable': notifyAvailable,
    'notifyBusy': notifyBusy,
    'notifyUnavailable': notifyUnavailable,
  };

  factory FuelAlert.fromJson(Map<String, dynamic> json) => FuelAlert(
    id: json['id'] ?? json['stationId'] ?? '',
    stationId: json['stationId'] ?? '',
    stationName: json['stationName'] ?? '',
    fuelTypes: List<String>.from(json['fuelTypes'] ?? []),
    isEnabled: json['isEnabled'] ?? true,
    notifyAvailable: json['notifyAvailable'] ?? true,
    notifyBusy: json['notifyBusy'] ?? true,
    notifyUnavailable: json['notifyUnavailable'] ?? true,
  );
}
