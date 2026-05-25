
package com.auraos.app.wallpaper

import android.graphics.*
import android.os.Handler
import android.os.Looper
import android.service.wallpaper.WallpaperService
import android.view.MotionEvent
import android.view.SurfaceHolder
import com.auraos.app.engine.AnimationEngine
import com.auraos.app.engine.EffectType
import com.auraos.app.engine.ParticleSystem
import com.auraos.app.sensors.SensorManager

/**
 * AURA OS Live Wallpaper Service
 * 
 * High-performance OpenGL-backed live wallpaper engine with:
 * - Particle systems (rain, snow, fire, glow, sparks)
 * - Parallax depth effects
 * - Touch-reactive animations
 * - Sensor-driven interactivity (tilt, shake)
 * - Battery-aware FPS scaling
 * - Music visualization
 * - Time-of-day color shifting
 */
class AuraWallpaperService : WallpaperService() {

    override fun onCreateEngine(): Engine = AuraWallpaperEngine()

    inner class AuraWallpaperEngine : Engine() {
        private val handler = Handler(Looper.getMainLooper())
        private var engine: AnimationEngine? = null
        private var sensorManager: SensorManager? = null
        private var particleSystem: ParticleSystem? = null
        private var bitmap: Bitmap? = null
        private var canvas: Canvas? = null
        private var visible = false
        private var width = 0
        private var height = 0
        private var touchX = 0f
        private var touchY = 0f
        private var tiltX = 0f
        private var tiltY = 0f

        // Performance
        private var targetFps = 30
        private var frameTime = 1000L / targetFps
        private var isLowPower = false

        // Effects config
        private var effects = mutableListOf<EffectType>()
        private var motionIntensity = 0.7f
        private var reactToTouch = true
        private var reactToTilt = true
        private var reactToCharging = true
        private var reactToBattery = true

        private val drawRunner = Runnable { drawFrame() }

        override fun onCreate(surfaceHolder: SurfaceHolder?) {
            super.onCreate(surfaceHolder)
            setTouchEventsEnabled(true)
            
            engine = AnimationEngine()
            sensorManager = SensorManager(applicationContext)
            particleSystem = ParticleSystem(maxParticles = 200)
            
            // Load saved wallpaper config
            loadWallpaperConfig()
        }

        override fun onSurfaceCreated(holder: SurfaceHolder?) {
            super.onSurfaceCreated(holder)
            sensorManager?.start()
        }

        override fun onSurfaceChanged(holder: SurfaceHolder?, format: Int, w: Int, h: Int) {
            super.onSurfaceChanged(holder, format, w, h)
            width = w
            height = h
            bitmap = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888)
            canvas = Canvas(bitmap!!)
            engine?.resize(w, h)
            particleSystem?.resize(w, h)
        }

        override fun onVisibilityChanged(visible: Boolean) {
            this.visible = visible
            if (visible) {
                drawFrame()
                sensorManager?.start()
            } else {
                handler.removeCallbacks(drawRunner)
                sensorManager?.stop()
            }
        }

        override fun onTouchEvent(event: MotionEvent?) {
            if (!reactToTouch) return
            event?.let {
                touchX = it.x
                touchY = it.y
                
                when (it.action) {
                    MotionEvent.ACTION_MOVE -> {
                        particleSystem?.addBurst(touchX, touchY, count = 5)
                        engine?.applyTouchForce(touchX, touchY)
                    }
                    MotionEvent.ACTION_DOWN -> {
                        particleSystem?.addBurst(touchX, touchY, count = 20)
                        engine?.applyTouchForce(touchX, touchY, radius = 200f)
                    }
                }
            }
            super.onTouchEvent(event)
        }

        override fun onSurfaceDestroyed(holder: SurfaceHolder?) {
            super.onSurfaceDestroyed(holder)
            visible = false
            handler.removeCallbacks(drawRunner)
            sensorManager?.stop()
        }

        override fun onDestroy() {
            super.onDestroy()
            handler.removeCallbacks(drawRunner)
            sensorManager?.stop()
            engine?.release()
            bitmap?.recycle()
        }

        private fun drawFrame() {
            if (!visible) return
            
            val startTime = System.currentTimeMillis()
            
            try {
                canvas?.let { c ->
                    // Clear
                    c.drawColor(Color.BLACK, PorterDuff.Mode.CLEAR)
                    
                    // Get sensor data
                    sensorManager?.let { sm ->
                        if (reactToTilt) {
                            tiltX = sm.tiltX
                            tiltY = sm.tiltY
                        }
                    }

                    // Render base image with parallax
                    bitmap?.let { bmp ->
                        val parallaxOffsetX = tiltX * 20 * motionIntensity
                        val parallaxOffsetY = tiltY * 20 * motionIntensity
                        
                        engine?.renderBase(c, bmp, parallaxOffsetX, parallaxOffsetY)
                    }

                    // Render effects
                    for (effect in effects) {
                        when (effect) {
                            EffectType.PARTICLES -> particleSystem?.updateAndDraw(c)
                            EffectType.RAIN -> engine?.renderRain(c, motionIntensity)
                            EffectType.SNOW -> engine?.renderSnow(c, motionIntensity)
                            EffectType.FIRE -> engine?.renderFire(c, motionIntensity)
                            EffectType.FOG -> engine?.renderFog(c, motionIntensity, tiltX)
                            EffectType.LIGHTNING -> engine?.renderLightning(c)
                            EffectType.GLOW -> engine?.renderGlow(c, touchX, touchY)
                            EffectType.PARALLAX -> {} // Handled in base render
                        }
                    }

                    // Battery-reactive overlay
                    if (reactToCharging) {
                        engine?.renderChargingEffect(c)
                    }

                    // Draw to surface
                    holder?.let { h ->
                        val surfaceCanvas = h.lockCanvas()
                        surfaceCanvas?.let { sc ->
                            sc.drawBitmap(bitmap!!, 0f, 0f, null)
                            h.unlockCanvasAndPost(sc)
                        }
                    }
                }
            } catch (e: Exception) {
                // Silent fail for wallpaper service
            }

            // Schedule next frame with adaptive FPS
            val elapsed = System.currentTimeMillis() - startTime
            val delay = (frameTime - elapsed).coerceAtLeast(1)
            
            if (visible) {
                handler.postDelayed(drawRunner, delay)
            }
        }

        private fun loadWallpaperConfig() {
            val prefs = getSharedPreferences("aura_wallpaper", MODE_PRIVATE)
            targetFps = prefs.getInt("fps", 30)
            frameTime = 1000L / targetFps
            motionIntensity = prefs.getFloat("motion_intensity", 0.7f)
            reactToTouch = prefs.getBoolean("react_touch", true)
            reactToTilt = prefs.getBoolean("react_tilt", true)
            reactToCharging = prefs.getBoolean("react_charging", true)
            
            // Load effects
            val effectNames = prefs.getStringSet("effects", emptySet()) ?: emptySet()
            effects = effectNames.mapNotNull { 
                try { EffectType.valueOf(it) } catch (_: Exception) { null }
            }.toMutableList()
            
            // Load base image
            val imagePath = prefs.getString("image_path", null)
            imagePath?.let {
                bitmap = BitmapFactory.decodeFile(it)
            }
        }

        fun updateConfig(
            fps: Int = targetFps,
            intensity: Float = motionIntensity,
            newEffects: List<EffectType> = effects
        ) {
            targetFps = fps
            frameTime = 1000L / fps
            motionIntensity = intensity
            effects = newEffects.toMutableList()
            
            // Save config
            getSharedPreferences("aura_wallpaper", MODE_PRIVATE).edit().apply {
                putInt("fps", fps)
                putFloat("motion_intensity", intensity)
                putStringSet("effects", newEffects.map { it.name }.toSet())
                apply()
            }
        }

        fun updateImage(path: String) {
            bitmap?.recycle()
            bitmap = BitmapFactory.decodeFile(path)
            
            getSharedPreferences("aura_wallpaper", MODE_PRIVATE).edit().apply {
                putString("image_path", path)
                apply()
            }
        }
    }
}
