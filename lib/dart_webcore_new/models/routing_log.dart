class RoutingLog {
  final DateTime startTime;
  final DateTime endTime;

  const RoutingLog({
    required this.startTime,
    required this.endTime,
  });

  Map<String, dynamic> toJSON() {
    String timeTakenInMs = (endTime.difference(startTime).inMicroseconds / 1000)
        .toStringAsFixed(2);
    return {
      'received': startTime.toIso8601String(),
      'abandoned': endTime.toIso8601String(),
      // 'closed': closed,
      // 'closeMsg': closeMessage,
      'timeTaken': '$timeTakenInMs ms',
    };
  }
}
