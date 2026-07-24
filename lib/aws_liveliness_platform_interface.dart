import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'aws_liveliness_method_channel.dart';

abstract class AwsLivelinessPlatform extends PlatformInterface {
  AwsLivelinessPlatform() : super(token: _token);

  static final Object _token = Object();

  static AwsLivelinessPlatform _instance = MethodChannelAwsLiveliness();

  static AwsLivelinessPlatform get instance => _instance;

  static set instance(AwsLivelinessPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<Map<String, dynamic>> startLivenessCheck({
    required String sessionId,
    required String region,
  }) {
    throw UnimplementedError('startLivenessCheck() has not been implemented.');
  }
}
