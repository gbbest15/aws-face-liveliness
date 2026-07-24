import 'aws_liveliness_platform_interface.dart';

class AwsLiveliness {
  Future<String?> getPlatformVersion() {
    return AwsLivelinessPlatform.instance.getPlatformVersion();
  }

  /// Starts a Face Liveness check.
  ///
  /// [sessionId] must come from your backend's CreateFaceLivenessSession
  /// (Rekognition) call — the plugin cannot create it itself.
  /// [region] is the AWS region the session was created in, e.g. "us-east-1".
  ///
  /// Returns a map with `status`: "completed" or "error", and `message`
  /// present when `status` is "error".
  Future<Map<String, dynamic>> startLivenessCheck({
    required String sessionId,
    required String region,
  }) {
    return AwsLivelinessPlatform.instance.startLivenessCheck(
      sessionId: sessionId,
      region: region,
    );
  }
}
