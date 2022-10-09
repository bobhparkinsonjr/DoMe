enum EmailValidateType {
  valid,

  invalidEmpty,

  invalidMissingAtSign,
  invalidTooManyAtSigns,

  invalidMissingDot,
  invalidTooManyDots,

  // nothing found before @
  invalidMissingPreAtContent,

  // nothing found between @ and .
  invalidMissingCenterContent,

  // nothing found after .
  invalidMissingPostDotContent,
}

class EmailValidator {
  static EmailValidateType validate(String email) {
    if (email.isEmpty) return EmailValidateType.invalidEmpty;

    int atResult = _findUniqueSymbol(email, '@');
    if (atResult == -1) return EmailValidateType.invalidMissingAtSign;
    if (atResult == -2) return EmailValidateType.invalidTooManyAtSigns;

    int dotResult = _findUniqueSymbol(email, '.');
    if (dotResult == -1) return EmailValidateType.invalidMissingDot;
    if (dotResult == -2) return EmailValidateType.invalidTooManyDots;

    if (atResult <= 0) return EmailValidateType.invalidMissingPreAtContent;
    if ((atResult + 1) >= dotResult) return EmailValidateType.invalidMissingCenterContent;
    if (dotResult >= (email.length - 1)) return EmailValidateType.invalidMissingPostDotContent;

    return EmailValidateType.valid;
  }

  static String getValidateMessage(EmailValidateType v) {
    switch (v) {
      case EmailValidateType.valid:
        return 'Email address is valid.';

      case EmailValidateType.invalidEmpty:
        return 'An email address is required.';

      case EmailValidateType.invalidMissingAtSign:
        return 'An \'@\' symbol is required.';

      case EmailValidateType.invalidTooManyAtSigns:
        return 'Only one \'@\' symbol is allowed.';

      case EmailValidateType.invalidMissingDot:
        return 'A \'.\' symbol is required.';

      case EmailValidateType.invalidTooManyDots:
        return 'Only one \'.\' symbol is allowed.';

      case EmailValidateType.invalidMissingPreAtContent:
        return 'Email address must have text before the \'@\' symbol.';

      case EmailValidateType.invalidMissingCenterContent:
        return 'Email address must contain text between the \'@\' and \'.\' symbols.';

      case EmailValidateType.invalidMissingPostDotContent:
        return 'Email address must have text following the \'.\' symbol.';

      default:
        // empty
        break;
    }

    return '';
  }

  // -1 => missing symbol
  // -2 => more than one symbol
  // returns index of unique symbol on success
  static int _findUniqueSymbol(String email, String symbol) {
    int i = email.indexOf(symbol);
    if (i <= 0) return -1;

    int i2 = email.indexOf(symbol, i + 1);
    if (i2 >= 0) return -2;

    return i;
  }
}
