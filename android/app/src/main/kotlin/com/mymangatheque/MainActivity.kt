package com.mymangatheque

import android.content.Intent
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            COLLECTION_IMPORT_CHANNEL,
        ).setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "start" -> {
                        val intent = Intent(
                            this,
                            CollectionImportForegroundService::class.java,
                        ).apply {
                            action = CollectionImportForegroundService.ACTION_START
                            putExtra(
                                CollectionImportForegroundService.EXTRA_TOTAL,
                                call.argument<Int>("total") ?: 0,
                            )
                        }
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                            startForegroundService(intent)
                        } else {
                            startService(intent)
                        }
                        result.success(null)
                    }

                    "update" -> {
                        val intent = Intent(
                            this,
                            CollectionImportForegroundService::class.java,
                        ).apply {
                            action = CollectionImportForegroundService.ACTION_UPDATE
                            putExtra(
                                CollectionImportForegroundService.EXTRA_COMPLETED,
                                call.argument<Int>("completed") ?: 0,
                            )
                            putExtra(
                                CollectionImportForegroundService.EXTRA_TOTAL,
                                call.argument<Int>("total") ?: 0,
                            )
                            putExtra(
                                CollectionImportForegroundService.EXTRA_TITLE,
                                call.argument<String>("title").orEmpty(),
                            )
                        }
                        startService(intent)
                        result.success(null)
                    }

                    "stop" -> {
                        stopService(
                            Intent(
                                this,
                                CollectionImportForegroundService::class.java,
                            ),
                        )
                        result.success(null)
                    }

                    else -> result.notImplemented()
                }
            } catch (error: Exception) {
                result.error(
                    "COLLECTION_IMPORT_FOREGROUND_SERVICE",
                    error.message,
                    null,
                )
            }
        }
    }

    companion object {
        private const val COLLECTION_IMPORT_CHANNEL =
            "com.mymangatheque/collection_import_foreground"
    }
}
