/// Parses raw SSE (Server-Sent Events) data lines.
class SseParser {
  SseParser._();

  /// Returns the parsed JSON data string from an SSE line, or null if the line
  /// does not contain meaningful data (empty lines, comments, [DONE]).
  static String? parseLine(String line) {
    if (line.isEmpty || line.startsWith(':')) return null;
    if (line.startsWith('data: ')) {
      final data = line.substring(6);
      if (data == '[DONE]') return null;
      return data;
    }
    // Anthropic SSE: some events have a leading "event:" line that we skip
    if (line.startsWith('event: ')) return null;
    return null;
  }
}
