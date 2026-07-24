package com.alveus.awsliveliness_tech.aws_liveliness


import android.content.Intent
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.material3.MaterialTheme
import com.amplifyframework.ui.liveness.ui.FaceLivenessDetector
import com.amplifyframework.ui.liveness.ui.LivenessColorScheme

class LivenessActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val sessionId = intent.getStringExtra("sessionId")
        val region = intent.getStringExtra("region")

        if (sessionId == null || region == null) {
            setResult(RESULT_CANCELED, Intent().putExtra("error", "Missing sessionId or region"))
            finish()
            return
        }

        setContent {
            MaterialTheme(colorScheme = LivenessColorScheme.default()) {
                FaceLivenessDetector(
                    sessionId = sessionId,
                    region = region,
                    onComplete = { setResult(RESULT_OK); finish() },
                    onError = { error ->
                        setResult(RESULT_CANCELED, Intent().putExtra("error", error.toString()))
                        finish()
                    }
                )
            }
        }
    }
}