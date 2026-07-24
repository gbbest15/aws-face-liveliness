# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.0.1+1] - 2026-07-24

### Changed

- Updated Android documentation to include Kotlin Compose plugin requirement
- Updated Android dependency versions:
  - `com.amplifyframework.ui:liveness` to 1.4.0
  - Added `androidx.appcompat:appcompat:1.7.0`
  - Updated `com.android.tools:desugar_jdk_libs` to 2.1.5
- Added `org.jetbrains.kotlin.plugin.compose` plugin to Android setup instructions
- Updated Android setup steps to include Compose compiler configuration

## [0.0.1] - 2026-07-24

### Added

- Initial release of `aws_liveliness`.
- `AwsLiveliness.startLivenessCheck({ sessionId, region })` — launches AWS
  Amplify Face Liveness detection UI on Android and iOS and returns the
  result to Dart.
- `AwsLiveliness.getPlatformVersion()` — basic platform version check, useful
  for verifying the plugin is correctly linked.
- Android implementation using `com.amplifyframework.ui:liveness`
  (Jetpack Compose `FaceLivenessDetector`), with automatic camera permission
  handling and safe Amplify auto-configuration.
- iOS implementation using Amplify's `FaceLivenessDetectorView` (SwiftUI),
  presented via `UIHostingController`, with the same safe Amplify
  auto-configuration behavior.
- Dual iOS dependency support: `Package.swift` (Swift Package Manager) and
  `.podspec` (CocoaPods), so the plugin works in both SPM-migrated and
  legacy CocoaPods host apps.
- Example app demonstrating end-to-end usage.

### Notes

- This is an early release. The public API (`startLivenessCheck` result
  shape in particular) may change before `1.0.0` based on feedback — see
  the README for the current contract.