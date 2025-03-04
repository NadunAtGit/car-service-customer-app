// validations.dart

// Function to validate email format
String? validateEmail(String email) {
  // Regular expression pattern for email validation
  final emailRegex = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");

  // Check if the email matches the regular expression pattern
  if (email.isEmpty) {
    return 'Email cannot be empty';
  } else if (!emailRegex.hasMatch(email)) {
    return 'Enter a valid email address';
  }
  return null; // Return null if the email is valid
}



// Function to validate Sri Lankan phone numbers with valid codes
String? validateSriLankanPhoneNumber(String phoneNumber) {
  // List of valid Sri Lankan service provider and district codes
  const validCodes = [
    "071", "072", "073", "074", "075", "076", "077", "078", "079", "070", // Service Providers
    "035", "036", "037", "038", "039", "041", "042", "043", "044", "045", "046", "047", "048", "049", // District Codes
    "011", "012", "013", "014", "015", "016", "017", "018", "019"  // Other valid codes
  ];

  // Check if phone number is empty
  if (phoneNumber.isEmpty) {
    return 'Phone number cannot be empty';
  }

  // Check if the first 3 digits are in the validCodes array
  final code = phoneNumber.substring(0, 3);

  if (!validCodes.contains(code)) {
    return 'Enter a valid Sri Lankan phone number'; // Invalid code
  }

  // Check if the remaining 7 digits are numeric
  final remainingDigits = phoneNumber.substring(3);

  if (!RegExp(r"^[0-9]{7}$").hasMatch(remainingDigits)) {
    return 'Enter a valid phone number with 7 digits after the area code';
  }

  return null; // Return null if phone number is valid
}


// Function to compare the entered password and the confirmation password
String? comparePasswords(String password, String confirmPassword) {
  if (password != confirmPassword) {
    return 'Passwords do not match';
  }
  return null; // Return null if passwords match
}
