final _print = print;

class Logger {
  /// use this method to ensure the entire message is printed to the console
  static void print(String text) {
    try {
      int total = text.length;

      const int n = 1000;
      int startIndex = 0;
      int endIndex = n;
      while (startIndex < total) {
        if (endIndex > total) endIndex = total;
        _print(text.substring(startIndex, endIndex));
        startIndex += n;
        endIndex = startIndex + n;
      }
    } catch (e) {
      _print('Logger.print failed | exception: \'${e.toString()}\'');
    }
  }
}
