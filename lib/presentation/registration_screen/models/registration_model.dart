// ignore_for_file: must_be_immutable

import 'dart:convert';

class RegistrationModel {
  RegistrationModel({
    this.currentStep = 1,
    this.totalSteps = 4,
    
    // Step 1: Personal Information
    this.firstName = "",
    this.lastName = "",
    this.phoneNumber = "",
    this.email = "",
    this.dateOfBirth = "",
    this.address = "",
    this.city = "",
    
    // Step 2: Account Setup
    this.username = "",
    this.password = "",
    this.confirmPassword = "",
    this.pin = "",
    this.confirmPin = "",
    
    // Step 3: Account Type Selection
    this.accountType,
    
    // Step 4: Terms & Conditions
    this.termsAccepted = false,
    this.privacyAccepted = false,
    this.marketingAccepted = false,
  });

  // Registration Progress
  int currentStep;
  int totalSteps;

  // Step 1: Personal Information
  String firstName;
  String lastName;
  String phoneNumber;
  String email;
  String dateOfBirth;
  String address;
  String city;

  // Step 2: Account Setup
  String username;
  String password;
  String confirmPassword;
  String pin;
  String confirmPin;

  // Step 3: Account Type Selection
  String? accountType;

  // Step 4: Terms & Conditions
  bool termsAccepted;
  bool privacyAccepted;
  bool marketingAccepted;

  RegistrationModel copyWith({
    int? currentStep,
    int? totalSteps,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? email,
    String? dateOfBirth,
    String? address,
    String? city,
    String? username,
    String? password,
    String? confirmPassword,
    String? pin,
    String? confirmPin,
    String? accountType,
    bool? termsAccepted,
    bool? privacyAccepted,
    bool? marketingAccepted,
  }) {
    return RegistrationModel(
      currentStep: currentStep ?? this.currentStep,
      totalSteps: totalSteps ?? this.totalSteps,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      address: address ?? this.address,
      city: city ?? this.city,
      username: username ?? this.username,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      pin: pin ?? this.pin,
      confirmPin: confirmPin ?? this.confirmPin,
      accountType: accountType ?? this.accountType,
      termsAccepted: termsAccepted ?? this.termsAccepted,
      privacyAccepted: privacyAccepted ?? this.privacyAccepted,
      marketingAccepted: marketingAccepted ?? this.marketingAccepted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentStep': currentStep,
      'totalSteps': totalSteps,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'email': email,
      'dateOfBirth': dateOfBirth,
      'address': address,
      'city': city,
      'username': username,
      'password': password,
      'confirmPassword': confirmPassword,
      'pin': pin,
      'confirmPin': confirmPin,
      'accountType': accountType,
      'termsAccepted': termsAccepted,
      'privacyAccepted': privacyAccepted,
      'marketingAccepted': marketingAccepted,
    };
  }

  factory RegistrationModel.fromJson(Map<String, dynamic> json) {
    return RegistrationModel(
      currentStep: json['currentStep'] ?? 1,
      totalSteps: json['totalSteps'] ?? 4,
      firstName: json['firstName'] ?? "",
      lastName: json['lastName'] ?? "",
      phoneNumber: json['phoneNumber'] ?? "",
      email: json['email'] ?? "",
      dateOfBirth: json['dateOfBirth'] ?? "",
      address: json['address'] ?? "",
      city: json['city'] ?? "",
      username: json['username'] ?? "",
      password: json['password'] ?? "",
      confirmPassword: json['confirmPassword'] ?? "",
      pin: json['pin'] ?? "",
      confirmPin: json['confirmPin'] ?? "",
      accountType: json['accountType'],
      termsAccepted: json['termsAccepted'] ?? false,
      privacyAccepted: json['privacyAccepted'] ?? false,
      marketingAccepted: json['marketingAccepted'] ?? false,
    );
  }

  @override
  String toString() {
    return json.encode(toJson());
  }

  bool get isStep1Valid {
    return firstName.isNotEmpty &&
           lastName.isNotEmpty &&
           phoneNumber.isNotEmpty &&
           email.isNotEmpty &&
           dateOfBirth.isNotEmpty;
  }

  bool get isStep2Valid {
    return username.isNotEmpty &&
           password.isNotEmpty &&
           confirmPassword.isNotEmpty &&
           password == confirmPassword &&
           pin.isNotEmpty &&
           confirmPin.isNotEmpty &&
           pin == confirmPin &&
           pin.length == 4;
  }

  bool get isStep3Valid {
    return accountType != null && accountType!.isNotEmpty;
  }

  bool get isStep4Valid {
    return termsAccepted && privacyAccepted;
  }

  bool get isCurrentStepValid {
    switch (currentStep) {
      case 1:
        return isStep1Valid;
      case 2:
        return isStep2Valid;
      case 3:
        return isStep3Valid;
      case 4:
        return isStep4Valid;
      default:
        return false;
    }
  }

  bool get canProceedToNextStep {
    return isCurrentStepValid && currentStep < totalSteps;
  }

  bool get canCompleteRegistration {
    return isStep1Valid && isStep2Valid && isStep3Valid && isStep4Valid;
  }

  // Password strength validation
  int get passwordStrength {
    if (password.isEmpty) return 0;
    
    int score = 0;
    
    // Length check
    if (password.length >= 8) score += 25;
    
    // Character variety checks
    if (RegExp(r'[A-Z]').hasMatch(password)) score += 25; // Uppercase
    if (RegExp(r'[a-z]').hasMatch(password)) score += 25; // Lowercase
    if (RegExp(r'[0-9]').hasMatch(password)) score += 12; // Numbers
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) score += 13; // Special chars
    
    return score;
  }

  String get passwordStrengthText {
    final strength = passwordStrength;
    if (strength == 0) return '';
    if (strength <= 25) return 'Faible';
    if (strength <= 50) return 'Moyen';
    if (strength <= 75) return 'Bon';
    return 'Excellent';
  }

  bool get isPasswordStrong {
    return passwordStrength >= 50;
  }
}