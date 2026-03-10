class Name {
  const Name({required this.first, required this.last});

  final String first;
  final String last;
  String get fullName => '$first $last';
}

class Utilisateur {
  Utilisateur({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.lastActive,
    this.avatarUrl = 'assets/images/avatars/boy.jpg',
    this.hasDriverProfile = false,
    this.isAdmin = false,
    this.isSupport = false,
    this.licenseNumber,
    this.phoneNumber,
    this.username
  });

  final String uid; // Unique identifier
  final Name name;
  final String email;
  final String avatarUrl; // 'assets/images/avatars/boy.jpg'
  final String password = 'P@ssw0rd!';
  final String? username;
  final String? licenseNumber;
  final String? phoneNumber;
  final bool isAdmin;
  final bool isSupport;
  final String bio = "Hello! I'm using U-GO.";
  final String location = "Unknown";
  final String language = "en"; // "en", "fr", "es", etc.
  final String currency = "USD"; // "USD", "EUR", etc. for payments
  final String preferredPaymentMethod = "credit_card"; // "credit_card", "paypal", etc.
  final double walletBalance = 0.0;
  final int loyaltyPoints = 0;
  final bool legalAccepted = true;
  final String referralCode = "REF12345";
  final String role; // "passenger", "driver", "admin" or "support"
  final int totalRatings = 0;
  final int totalBookings = 0;
  final int totalReviews = 0;
  final String activeRole = "passenger"; // "passenger" or "driver"
  final String accountStatus = "active"; // "active", "inactive", "banned"
  final String currentTier = "Gold"; // "Bronze", "Silver", "Gold", "Platinum" etc.
  final bool isDriverVerified = false;
  final String driverStatus = "offline"; // "online", "offline", "on-trip", "suspended", etc.
  final bool hasDriverLicense = false;
  final bool hasDriverProfile;
  final DateTime createdAt = DateTime.now();
  final DateTime updatedAt = DateTime.now();
  final DateTime lastActive;

}
