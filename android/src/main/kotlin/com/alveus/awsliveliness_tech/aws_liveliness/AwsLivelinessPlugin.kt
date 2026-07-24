package com.alveus.awsliveliness_tech.aws_liveliness

// import io.flutter.embedding.engine.plugins.FlutterPlugin
// import io.flutter.plugin.common.MethodCall
// import io.flutter.plugin.common.MethodChannel
// import io.flutter.plugin.common.MethodChannel.MethodCallHandler
// import io.flutter.plugin.common.MethodChannel.Result

// /** AwsLivelinessPlugin */
// class AwsLivelinessPlugin :
//     FlutterPlugin,
//     MethodCallHandler {
//     // The MethodChannel that will the communication between Flutter and native Android
//     //
//     // This local reference serves to register the plugin with the Flutter Engine and unregister it
//     // when the Flutter Engine is detached from the Activity
//     private lateinit var channel: MethodChannel

//     override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
//         channel = MethodChannel(flutterPluginBinding.binaryMessenger, "aws_liveliness")
//         channel.setMethodCallHandler(this)
//     }

//     override fun onMethodCall(
//         call: MethodCall,
//         result: Result
//     ) {
//         if (call.method == "getPlatformVersion") {
//             result.success("Android ${android.os.Build.VERSION.RELEASE}")
//         } else {
//             result.notImplemented()
//         }
//     }

//     override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
//         channel.setMethodCallHandler(null)
//     }
// }


import android.Manifest
import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.amplifyframework.auth.cognito.AWSCognitoAuthPlugin
import com.amplifyframework.core.Amplify
import com.amplifyframework.predictions.aws.AWSPredictionsPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry.ActivityResultListener
import io.flutter.plugin.common.PluginRegistry.RequestPermissionsResultListener

class AwsLivelinessPlugin :
    FlutterPlugin,
    MethodChannel.MethodCallHandler,
    ActivityAware,
    ActivityResultListener,
    RequestPermissionsResultListener {

    private lateinit var channel: MethodChannel
    private var activity: Activity? = null
    private var pendingResult: MethodChannel.Result? = null
    private var pendingSessionId: String? = null
    private var pendingRegion: String? = null

    companion object {
        private const val LIVENESS_REQUEST_CODE = 1001
        private const val CAMERA_PERMISSION_REQUEST_CODE = 2001
        private var amplifyConfigured = false
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "aws_liveliness")
        channel.setMethodCallHandler(this)
        ensureAmplifyConfigured(binding.applicationContext)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    // Safe whether the host app configures Amplify itself (for other categories)
    // or leaves it entirely to this plugin.
    private fun ensureAmplifyConfigured(context: android.content.Context) {
        if (amplifyConfigured) return
        try {
            Amplify.addPlugin(AWSCognitoAuthPlugin())
            Amplify.addPlugin(AWSPredictionsPlugin())
            Amplify.configure(context)
            amplifyConfigured = true
        } catch (error: Exception) {
            android.util.Log.w("AwsLivelinessPlugin", "Amplify configure skipped/failed: $error")
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method != "startLivenessCheck") {
            result.notImplemented()
            return
        }
        val currentActivity = activity
        if (currentActivity == null) {
            result.error("NO_ACTIVITY", "Plugin not attached to an activity", null)
            return
        }
        val sessionId = call.argument<String>("sessionId")
        val region = call.argument<String>("region")
        if (sessionId == null || region == null) {
            result.error("BAD_ARGS", "Missing sessionId or region", null)
            return
        }

        pendingResult = result
        pendingSessionId = sessionId
        pendingRegion = region

        if (ContextCompat.checkSelfPermission(currentActivity, Manifest.permission.CAMERA)
            == PackageManager.PERMISSION_GRANTED
        ) {
            launchLiveness(currentActivity, sessionId, region)
        } else {
            ActivityCompat.requestPermissions(
                currentActivity, arrayOf(Manifest.permission.CAMERA), CAMERA_PERMISSION_REQUEST_CODE
            )
        }
    }

    private fun launchLiveness(activity: Activity, sessionId: String, region: String) {
        val intent = Intent(activity, LivenessActivity::class.java).apply {
            putExtra("sessionId", sessionId)
            putExtra("region", region)
        }
        activity.startActivityForResult(intent, LIVENESS_REQUEST_CODE)
    }

    override fun onRequestPermissionsResult(
        requestCode: Int, permissions: Array<out String>, grantResults: IntArray
    ): Boolean {
        if (requestCode != CAMERA_PERMISSION_REQUEST_CODE) return false
        val granted = grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED
        val sessionId = pendingSessionId
        val region = pendingRegion
        val currentActivity = activity

        if (granted && sessionId != null && region != null && currentActivity != null) {
            launchLiveness(currentActivity, sessionId, region)
        } else if (!granted) {
            pendingResult?.error("CAMERA_PERMISSION_DENIED", "Camera permission denied", null)
            pendingResult = null
        }
        return true
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode != LIVENESS_REQUEST_CODE) return false
        if (resultCode == Activity.RESULT_OK) {
            pendingResult?.success(mapOf("isLive" to true))
        } else {
            pendingResult?.error("LIVENESS_FAILED", data?.getStringExtra("error") ?: "Unknown error", null)
        }
        pendingResult = null
        return true
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addActivityResultListener(this)
        binding.addRequestPermissionsResultListener(this)
    }
    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addActivityResultListener(this)
        binding.addRequestPermissionsResultListener(this)
    }
    override fun onDetachedFromActivityForConfigChanges() { activity = null }
    override fun onDetachedFromActivity() { activity = null }
}