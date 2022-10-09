enum PasswordValidateType {
  valid,

  invalidEmpty,

  invalidTooShort,
  invalidTooLong,

  invalidMissingLetter,
  invalidMissingDigit,
}

class PasswordValidator {
  static const int passwordMinLength = 6;
  static const int passwordMaxLength = 32;

  static PasswordValidateType validate(String password) {
    if (password.isEmpty) return PasswordValidateType.invalidEmpty;

    if (password.length < passwordMinLength) return PasswordValidateType.invalidTooShort;
    if (password.length > passwordMaxLength) return PasswordValidateType.invalidTooLong;

    if (!(password.contains(RegExp(r'[a-zA-Z]+')))) return PasswordValidateType.invalidMissingLetter;
    if (!(password.contains(RegExp(r'[0-9]+')))) return PasswordValidateType.invalidMissingDigit;

    return PasswordValidateType.valid;
  }

  static String getValidateMessage(PasswordValidateType v) {
    switch (v) {
      case PasswordValidateType.valid:
        return 'Password is valid.';

      case PasswordValidateType.invalidEmpty:
        return 'A password is required.';

      case PasswordValidateType.invalidTooShort:
        return 'Password must be at least $passwordMinLength characters long.';

      case PasswordValidateType.invalidTooLong:
        return 'Password cannot be longer than $passwordMaxLength characters.';

      case PasswordValidateType.invalidMissingLetter:
        return 'Password must contain at least one letter.';

      case PasswordValidateType.invalidMissingDigit:
        return 'Password must contain at least one digit.';

      default:
        // empty
        break;
    }

    return '';
  }
}
