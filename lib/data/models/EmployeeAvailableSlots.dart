class EmployeeAvailableSlots {
  final String employeeId;
  final String employeeName;
  final List<String> availableSlots;

  EmployeeAvailableSlots({
    required this.employeeId,
    required this.employeeName,
    required this.availableSlots,
  });

  Map<String, dynamic> toJson() => {
    'employeeId': employeeId,
    'employeeName': employeeName,
    'availableSlots': availableSlots,
  };

  factory EmployeeAvailableSlots.fromJson(Map<String, dynamic> json) =>
      EmployeeAvailableSlots(
        employeeId: json['employeeId'],
        employeeName: json['employeeName'],
        availableSlots: List<String>.from(json['availableSlots']),
      );
}
