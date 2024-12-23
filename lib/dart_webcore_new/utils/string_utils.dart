extension StringUtils on String {
  String strip(
    String stripped, {
    bool all = true,
  }) =>
      all ? _stripStringAll(this, stripped) : _stripString(this, stripped);
}

/// this will strip the stripped from the text if it starts or ends with it
String _stripString(String text, String stripped) {
  String copy = text;
  if (copy.startsWith(stripped)) {
    copy = copy.substring(stripped.length);
  }

  if (copy.endsWith(stripped)) {
    copy = copy.substring(0, copy.length - stripped.length);
  }
  return copy;
}

String _stripStringAll(String text, String stripped) {
  String input = text;
  String? output;
  while (true) {
    output = _stripString(input, stripped);
    if (output == input) {
      break;
    } else {
      input = output;
    }
  }

  return output;
}
