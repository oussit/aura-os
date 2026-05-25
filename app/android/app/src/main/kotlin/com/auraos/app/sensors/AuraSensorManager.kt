
package com.auraos.app.sensors

import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager as AndroidSensorManager

class SensorManager(context: Context) : SensorEventListener {
    private val sensorManager = context.getSystemService(Context.SENSOR_SERVICE) as AndroidSensorManager
    private val accelerometer = sensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)
    private val gyroscope = sensorManager.getDefaultSensor(Sensor.TYPE_GYROSCOPE)
    
    var tiltX = 0f
        private set
    var tiltY = 0f
        private set
    var tiltZ = 0f
        private set
    
    var gyroX = 0f
        private set
    var gyroY = 0f
        private set
    var gyroZ = 0f
        private set

    // Smoothed values
    private val alpha = 0.15f // Low-pass filter coefficient
    
    fun start() {
        accelerometer?.let {
            sensorManager.registerListener(this, it, AndroidSensorManager.SENSOR_DELAY_GAME)
        }
        gyroscope?.let {
            sensorManager.registerListener(this, it, AndroidSensorManager.SENSOR_DELAY_GAME)
        }
    }
    
    fun stop() {
        sensorManager.unregisterListener(this)
    }

    override fun onSensorChanged(event: SensorEvent?) {
        event ?: return
        
        when (event.sensor.type) {
            Sensor.TYPE_ACCELEROMETER -> {
                tiltX = lerp(tiltX, event.values[0], alpha)
                tiltY = lerp(tiltY, event.values[1], alpha)
                tiltZ = lerp(tiltZ, event.values[2], alpha)
            }
            Sensor.TYPE_GYROSCOPE -> {
                gyroX = lerp(gyroX, event.values[0], alpha)
                gyroY = lerp(gyroY, event.values[1], alpha)
                gyroZ = lerp(gyroZ, event.values[2], alpha)
            }
        }
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}
    
    private fun lerp(current: Float, target: Float, factor: Float): Float {
        return current + factor * (target - current)
    }
}
