import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'aws_liveliness_platform_interface.dart';

class MethodChannelAwsLiveliness extends AwsLivelinessPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('aws_liveliness');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }

  @override
  Future<Map<String, dynamic>> startLivenessCheck({
    required String sessionId,
    required String region,
  }) async {
    try {
      final result = await methodChannel.invokeMapMethod<String, dynamic>(
        'startLivenessCheck',
        {'sessionId': sessionId, 'region': region},
      );
      return result ?? {'status': 'unknown'};
    } on PlatformException catch (e) {
      // Surface the real native error instead of swallowing it
      return {'status': 'error', 'message': e.message ?? e.code};
    }
  }
}
