import 'operating_hour.dart';

/// Salon model representing a barbershop/salon
class SalonModel {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final String? email;
  final String? phone;
  final String? address;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? country;
  final String? logo;
  final String? coverImage;
  final String? website;
  final String timezone;
  final String currency;
  final bool allowOnlineBooking;
  final bool requireBookingApproval;
  final int defaultSlotInterval;
  final int maxAdvanceBookingDays;
  final int minAdvanceBookingHours;
  final bool isActive;
  final List<OperatingHour> operatingHours;
  final DateTime createdAt;
  final DateTime updatedAt;

  SalonModel({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.email,
    this.phone,
    this.address,
    this.city,
    this.state,
    this.zipCode,
    this.country,
    this.logo,
    this.coverImage,
    this.website,
    this.timezone = 'America/Sao_Paulo',
    this.currency = 'BRL',
    this.allowOnlineBooking = true,
    this.requireBookingApproval = false,
    this.defaultSlotInterval = 10,
    this.maxAdvanceBookingDays = 90,
    this.minAdvanceBookingHours = 2,
    this.isActive = true,
    this.operatingHours = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory SalonModel.fromJson(Map<String, dynamic> json) {
    return SalonModel(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      zipCode: json['zipCode'] as String?,
      country: json['country'] as String?,
      logo: json['logo'] as String?,
      coverImage: json['coverImage'] as String?,
      website: json['website'] as String?,
      timezone: json['timezone'] as String? ?? 'America/Sao_Paulo',
      currency: json['currency'] as String? ?? 'BRL',
      allowOnlineBooking: json['allowOnlineBooking'] as bool? ?? true,
      requireBookingApproval: json['requireBookingApproval'] as bool? ?? false,
      defaultSlotInterval: json['defaultSlotInterval'] as int? ?? 10,
      maxAdvanceBookingDays: json['maxAdvanceBookingDays'] as int? ?? 90,
      minAdvanceBookingHours: json['minAdvanceBookingHours'] as int? ?? 2,
      isActive: json['isActive'] as bool? ?? true,
      operatingHours:
          (json['operatingHours'] as List<dynamic>?)
              ?.map((e) => OperatingHour.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'email': email,
      'phone': phone,
      'address': address,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'country': country,
      'logo': logo,
      'coverImage': coverImage,
      'website': website,
      'timezone': timezone,
      'currency': currency,
      'allowOnlineBooking': allowOnlineBooking,
      'requireBookingApproval': requireBookingApproval,
      'defaultSlotInterval': defaultSlotInterval,
      'maxAdvanceBookingDays': maxAdvanceBookingDays,
      'minAdvanceBookingHours': minAdvanceBookingHours,
      'isActive': isActive,
      'operatingHours': operatingHours.map((e) => e.toJson()).toList(),
    };
  }

  SalonModel copyWith({
    String? id,
    String? name,
    String? slug,
    String? description,
    String? email,
    String? phone,
    String? address,
    String? city,
    String? state,
    String? zipCode,
    String? country,
    String? logo,
    String? coverImage,
    String? website,
    String? timezone,
    String? currency,
    bool? allowOnlineBooking,
    bool? requireBookingApproval,
    int? defaultSlotInterval,
    int? maxAdvanceBookingDays,
    int? minAdvanceBookingHours,
    bool? isActive,
    List<OperatingHour>? operatingHours,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SalonModel(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      country: country ?? this.country,
      logo: logo ?? this.logo,
      coverImage: coverImage ?? this.coverImage,
      website: website ?? this.website,
      timezone: timezone ?? this.timezone,
      currency: currency ?? this.currency,
      allowOnlineBooking: allowOnlineBooking ?? this.allowOnlineBooking,
      requireBookingApproval:
          requireBookingApproval ?? this.requireBookingApproval,
      defaultSlotInterval: defaultSlotInterval ?? this.defaultSlotInterval,
      maxAdvanceBookingDays:
          maxAdvanceBookingDays ?? this.maxAdvanceBookingDays,
      minAdvanceBookingHours:
          minAdvanceBookingHours ?? this.minAdvanceBookingHours,
      isActive: isActive ?? this.isActive,
      operatingHours: operatingHours ?? this.operatingHours,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get operating hours for a specific day, or null if not set
  OperatingHour? getHoursForDay(int dayOfWeek) {
    try {
      return operatingHours.firstWhere((h) => h.dayOfWeek == dayOfWeek);
    } catch (_) {
      return null;
    }
  }
}
