import 'package:flutter_test/flutter_test.dart';
import 'package:aws_liveliness/aws_liveliness.dart';
import 'package:aws_liveliness/aws_liveliness_platform_interface.dart';
import 'package:aws_liveliness/aws_liveliness_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockAwsLivelinessPlatform
    with MockPlatformInterfaceMixin
    implements AwsLivelinessPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<Map<String, dynamic>> startLivenessCheck({
    required String sessionId,
    required String region,
  }) {
    return Future.value({'status': 'completed'});
  }
}

void main() {
  final AwsLivelinessPlatform initialPlatform = AwsLivelinessPlatform.instance;

  test('$MethodChannelAwsLiveliness is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelAwsLiveliness>());
  });

  test('getPlatformVersion', () async {
    AwsLiveliness awsLivelinessPlugin = AwsLiveliness();
    MockAwsLivelinessPlatform fakePlatform = MockAwsLivelinessPlatform();
    AwsLivelinessPlatform.instance = fakePlatform;

    expect(await awsLivelinessPlugin.getPlatformVersion(), '42');
  });

  test('startLivenessCheck', () async {
    AwsLiveliness awsLivelinessPlugin = AwsLiveliness();
    MockAwsLivelinessPlatform fakePlatform = MockAwsLivelinessPlatform();
    AwsLivelinessPlatform.instance = fakePlatform;

    final result = await awsLivelinessPlugin.startLivenessCheck(
      sessionId: 'test-session-id',
      region: 'us-east-1',
    );

    expect(result, {'status': 'completed'});
  });
}
