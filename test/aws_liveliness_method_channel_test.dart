import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_liveliness/aws_liveliness_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelAwsLiveliness platform = MethodChannelAwsLiveliness();
  const MethodChannel channel = MethodChannel('aws_liveliness');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          return '42';
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
