package com.mymangatheque

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.IBinder
import android.os.PowerManager

class CollectionImportForegroundService : Service() {
    private var wakeLock: PowerManager.WakeLock? = null
    private var completed = 0
    private var total = 0
    private var currentTitle = ""

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_START -> {
                completed = 0
                total = intent.getIntExtra(EXTRA_TOTAL, 0).coerceAtLeast(0)
                currentTitle = ""
                refreshWakeLock()
                startForeground(NOTIFICATION_ID, buildNotification())
            }

            ACTION_UPDATE -> {
                completed = intent.getIntExtra(EXTRA_COMPLETED, completed)
                    .coerceAtLeast(0)
                total = intent.getIntExtra(EXTRA_TOTAL, total).coerceAtLeast(0)
                currentTitle = intent.getStringExtra(EXTRA_TITLE).orEmpty()
                refreshWakeLock()
                notificationManager().notify(
                    NOTIFICATION_ID,
                    buildNotification(),
                )
            }
        }
        return START_NOT_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        releaseWakeLock()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            stopForeground(STOP_FOREGROUND_REMOVE)
        } else {
            @Suppress("DEPRECATION")
            stopForeground(true)
        }
        super.onDestroy()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val channel = NotificationChannel(
            CHANNEL_ID,
            getString(R.string.collection_import_channel_name),
            NotificationManager.IMPORTANCE_LOW,
        ).apply {
            description = getString(R.string.collection_import_channel_description)
            setSound(null, null)
            enableVibration(false)
        }
        notificationManager().createNotificationChannel(channel)
    }

    private fun buildNotification(): Notification {
        val launchIntent = packageManager.getLaunchIntentForPackage(packageName)
        val pendingIntent = launchIntent?.let {
            PendingIntent.getActivity(
                this,
                0,
                it,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
        }
        val progressText = if (total > 0) {
            getString(R.string.collection_import_progress, completed, total)
        } else {
            getString(R.string.collection_import_preparing)
        }
        val contentText = currentTitle
            .takeIf { it.isNotBlank() }
            ?.let { "$progressText · $it" }
            ?: progressText
        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, CHANNEL_ID)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(this)
        }
        return builder
            .setSmallIcon(R.drawable.ic_notification)
            .setContentTitle(getString(R.string.collection_import_notification_title))
            .setContentText(contentText)
            .setCategory(Notification.CATEGORY_PROGRESS)
            .setOnlyAlertOnce(true)
            .setOngoing(true)
            .setProgress(total, completed.coerceAtMost(total), total <= 0)
            .setContentIntent(pendingIntent)
            .build()
    }

    private fun refreshWakeLock() {
        val lock = wakeLock ?: (getSystemService(Context.POWER_SERVICE) as PowerManager)
            .newWakeLock(
                PowerManager.PARTIAL_WAKE_LOCK,
                "$packageName:collection-import",
            ).also {
                it.setReferenceCounted(false)
                wakeLock = it
            }
        if (lock.isHeld) lock.release()
        lock.acquire(WAKE_LOCK_TIMEOUT_MILLIS)
    }

    private fun releaseWakeLock() {
        wakeLock?.takeIf { it.isHeld }?.release()
        wakeLock = null
    }

    private fun notificationManager(): NotificationManager =
        getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

    companion object {
        const val ACTION_START = "com.mymangatheque.collection_import.START"
        const val ACTION_UPDATE = "com.mymangatheque.collection_import.UPDATE"
        const val EXTRA_COMPLETED = "completed"
        const val EXTRA_TOTAL = "total"
        const val EXTRA_TITLE = "title"

        private const val CHANNEL_ID = "collection_import_progress"
        private const val NOTIFICATION_ID = 42017
        private const val WAKE_LOCK_TIMEOUT_MILLIS = 10 * 60 * 1000L
    }
}
