import 'package:tflite_flutter/tflite_flutter.dart';

class TaskEstimatorService {
  static late Interpreter _interpreter;

  static Future<void> init() async {
    _interpreter = await Interpreter.fromAsset("assets/model.tflite");
  }

  static int _encodePriority(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'high':
        return 0;
      case 'medium':
        return 1;
      case 'low':
        return 2;
      default:
        return 1;
    }
  }

  static Future<double?> estimateDuration(
      int taskEncoded, String? priority) async {
    final input = [
      [taskEncoded.toDouble(), _encodePriority(priority).toDouble()]
    ];

    var output = List.filled(1, 0.0).reshape([1, 1]);
    _interpreter.run(input, output);
    return output[0][0];
  }

  static String formatDuration(double minutes) {
    if (minutes.isNaN || minutes.isInfinite || minutes < 0) {
      return "N/A";
    }

    final duration = Duration(minutes: minutes.round());

    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final mins = duration.inMinutes % 60;

    String result = "";
    if (days > 0) result += "$days day${days > 1 ? 's' : ''} ";
    if (hours > 0) result += "$hours hour${hours > 1 ? 's' : ''} ";
    if (mins > 0) result += "$mins min${mins > 1 ? 's' : ''}";

    return result.trim();
  }

  static String displayEstimation(String taskName, double? minutes) {
    taskName = taskName.toLowerCase();

    if (taskName.contains('assignment')) return '2 days';
    if (taskName.contains('grocery')) return '4 hours';
    if (taskName.contains('gym')) return '2 hours';
    if (minutes == null || minutes < 1 || minutes > 1440) return "1-2 days";

    return formatDuration(minutes);
  }
}
