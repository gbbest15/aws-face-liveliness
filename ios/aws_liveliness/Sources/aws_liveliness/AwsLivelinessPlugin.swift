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
        case "startLivenessCheck":
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
        guard ensureAmplifyConfigured() else {
            result(FlutterError(
                code: "AMPLIFY_MISCONFIGURED",
                message: "Amplify is configured without AWSCognitoAuthPlugin/AWSPredictionsPlugin, and plugins cannot be added after configure(). Configure Amplify with these plugins before calling startLivenessCheck, or let this plugin configure Amplify first.",
                details: nil
            ))
            return
        }

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

    /// Ensures Amplify is configured with the plugins Liveness needs.
    /// We can't check `Amplify.isConfigured` directly (it's `internal`), so
    /// we try to add + configure, and if that fails (most likely because the
    /// host app already called `Amplify.configure()`), we fall back to
    /// checking whether AWSPredictionsPlugin is already reachable.
    /// Returns `true` if Predictions is usable, `false` otherwise.
    @discardableResult
    private func ensureAmplifyConfigured() -> Bool {
        do {
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            try Amplify.add(plugin: AWSPredictionsPlugin())
            try Amplify.configure()
            return true
        } catch {
            // Likely already configured by the host app (or plugins already
            // added). Verify Predictions is actually usable rather than
            // trusting the error message.
            do {
                _ = try Amplify.Predictions.getPlugin(for: "awsPredictionsPlugin")
                return true
            } catch {
                print("""
                aws_liveliness: Amplify configuration issue — \(error). \
                If Amplify was already configured by the host app, it must \
                include AWSCognitoAuthPlugin and AWSPredictionsPlugin BEFORE \
                calling Amplify.configure(), since plugins cannot be added \
                afterward.
                """)
                return false
            }
        }
    }

    private static func currentRootViewController() -> UIViewController? {
        let keyWindow = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }

        return keyWindow?.rootViewController
    }
}