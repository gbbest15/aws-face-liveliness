import Flutter
import UIKit
import Amplify
import AWSPredictionsPlugin
import AWSCognitoAuthPlugin

public class AwsLivelinessPlugin: NSObject, FlutterPlugin {

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "aws_liveliness",
            binaryMessenger: registrar.messenger()
        )
        let instance = AwsLivelinessPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "aws_liveliness":
            guard let args = call.arguments as? [String: Any],
                  let sessionID = args["sessionId"] as? String,
                  let region = args["region"] as? String else {
                result(FlutterError(code: "BAD_ARGS", message: "Missing sessionId or region", details: nil))
                return
            }
            startLiveness(sessionID: sessionID, region: region, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func startLiveness(sessionID: String, region: String, result: @escaping FlutterResult) {
        ensureAmplifyConfigured()

        guard let rootVC = Self.currentRootViewController() else {
            result(FlutterError(code: "NO_ROOT_VC", message: "Could not find a presenting view controller", details: nil))
            return
        }

        LivenessPresenter.present(from: rootVC, sessionID: sessionID, region: region) { livenessResult in
            DispatchQueue.main.async {
                switch livenessResult {
                case .success:
                    result(["isLive": true])
                case .failure(let error):
                    result(FlutterError(code: "LIVENESS_FAILED", message: String(describing: error), details: nil))
                }
            }
        }
    }

    /// Configures Amplify only if the host app hasn't already. Safe to call
    /// on every check — never crashes on a host app that configures Amplify itself.
    private func ensureAmplifyConfigured() {
        guard !Amplify.isConfigured else { return }
        do {
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            try Amplify.add(plugin: AWSPredictionsPlugin())
            try Amplify.configure()
        } catch {
            // Swallow "already added" style errors from a race with host app config;
            // anything else will surface clearly when startLivenessCheck fails downstream.
            print("aws_liveliness: Amplify configure skipped/failed: \(error)")
        }
    }

    private static func currentRootViewController() -> UIViewController? {
        UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first?.rootViewController
    }
}