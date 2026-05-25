
package com.auraos.app.engine

import android.graphics.*
import kotlin.math.*
import kotlin.random.Random

enum class EffectType {
    PARTICLES, RAIN, SNOW, FIRE, FOG, LIGHTNING, GLOW, PARALLAX
}

class AnimationEngine {
    private var width = 0
    private var height = 0
    private val random = Random.Default
    
    // Cached paints
    private val rainPaint = Paint().apply {
        color = Color.argb(120, 150, 200, 255)
        strokeWidth = 2f
        strokeCap = Paint.Cap.ROUND
    }
    
    private val snowPaint = Paint().apply {
        color = Color.argb(200, 255, 255, 255)
        isAntiAlias = true
    }
    
    private val fogPaint = Paint().apply {
        isAntiAlias = true
        xfermode = PorterDuffXfermode(PorterDuff.Mode.SCREEN)
    }
    
    private val glowPaint = Paint().apply {
        isAntiAlias = true
        maskFilter = BlurMaskFilter(30f, BlurMaskFilter.Blur.NORMAL)
        xfermode = PorterDuffXfermode(PorterDuff.Mode.SCREEN)
    }

    // Rain drops
    private data class RainDrop(var x: Float, var y: Float, var speed: Float, var length: Float)
    private val rainDrops = mutableListOf<RainDrop>()
    
    // Snow flakes
    private data class SnowFlake(var x: Float, var y: Float, var speed: Float, var size: Float, var wobble: Float)
    private val snowFlakes = mutableListOf<SnowFlake>()
    
    // Fog particles
    private data class FogParticle(var x: Float, var y: Float, var size: Float, var alpha: Float, var speed: Float)
    private val fogParticles = mutableListOf<FogParticle>()

    // Touch force
    private var forceX = 0f
    private var forceY = 0f
    private var forceRadius = 100f
    private var forceStrength = 0f

    // Charging state
    private var isCharging = false
    private var chargePulse = 0f
    
    fun resize(w: Int, h: Int) {
        width = w
        height = h
        initParticles()
    }
    
    private fun initParticles() {
        rainDrops.clear()
        repeat(150) {
            rainDrops.add(RainDrop(
                x = random.nextFloat() * width,
                y = random.nextFloat() * height,
                speed = 15f + random.nextFloat() * 10f,
                length = 20f + random.nextFloat() * 30f
            ))
        }
        
        snowFlakes.clear()
        repeat(80) {
            snowFlakes.add(SnowFlake(
                x = random.nextFloat() * width,
                y = random.nextFloat() * height,
                speed = 1f + random.nextFloat() * 3f,
                size = 2f + random.nextFloat() * 4f,
                wobble = random.nextFloat() * 360f
            ))
        }
        
        fogParticles.clear()
        repeat(12) {
            fogParticles.add(FogParticle(
                x = random.nextFloat() * width,
                y = height * 0.5f + random.nextFloat() * height * 0.5f,
                size = 200f + random.nextFloat() * 400f,
                alpha = 10f + random.nextFloat() * 30f,
                speed = 0.3f + random.nextFloat() * 0.7f
            ))
        }
    }

    fun renderBase(canvas: Canvas, bitmap: Bitmap, offsetX: Float, offsetY: Float) {
        // Parallax rendering - draw image slightly offset based on tilt
        val src = Rect(0, 0, bitmap.width, bitmap.height)
        val margin = 40
        val dst = Rect(
            (-margin + offsetX).toInt(),
            (-margin + offsetY).toInt(),
            width + margin + offsetX.toInt(),
            height + margin + offsetY.toInt()
        )
        canvas.drawBitmap(bitmap, src, dst, null)
    }

    fun renderRain(canvas: Canvas, intensity: Float) {
        for (drop in rainDrops) {
            drop.y += drop.speed * intensity
            drop.x += 2f * intensity // slight wind
            
            if (drop.y > height) {
                drop.y = -drop.length
                drop.x = random.nextFloat() * width
            }
            
            rainPaint.alpha = (80 * intensity).toInt().coerceIn(20, 150)
            canvas.drawLine(drop.x, drop.y, drop.x + 2, drop.y + drop.length, rainPaint)
        }
    }

    fun renderSnow(canvas: Canvas, intensity: Float) {
        for (flake in snowFlakes) {
            flake.y += flake.speed * intensity
            flake.wobble += 0.02f
            flake.x += sin(flake.wobble).toFloat() * 1.5f
            
            if (flake.y > height + flake.size) {
                flake.y = -flake.size
                flake.x = random.nextFloat() * width
            }
            
            snowPaint.alpha = (150 * intensity).toInt().coerceIn(50, 220)
            canvas.drawCircle(flake.x, flake.y, flake.size, snowPaint)
        }
    }

    fun renderFire(canvas: Canvas, intensity: Float) {
        val firePaint = Paint().apply {
            xfermode = PorterDuffXfermode(PorterDuff.Mode.SCREEN)
        }
        
        for (i in 0 until (30 * intensity).toInt()) {
            val x = width * 0.3f + random.nextFloat() * width * 0.4f
            val y = height - random.nextFloat() * height * 0.3f
            val size = 20f + random.nextFloat() * 60f
            val gradient = RadialGradient(
                x, y, size,
                intArrayOf(
                    Color.argb(200, 255, 100, 0),
                    Color.argb(100, 255, 50, 0),
                    Color.argb(0, 255, 0, 0)
                ),
                floatArrayOf(0f, 0.5f, 1f),
                Shader.TileMode.CLAMP
            )
            firePaint.shader = gradient
            canvas.drawCircle(x, y, size, firePaint)
        }
    }

    fun renderFog(canvas: Canvas, intensity: Float, tiltX: Float) {
        for (fog in fogParticles) {
            fog.x += fog.speed + tiltX * 2
            if (fog.x > width + fog.size) fog.x = -fog.size
            if (fog.x < -fog.size) fog.x = width + fog.size
            
            val gradient = RadialGradient(
                fog.x, fog.y, fog.size,
                intArrayOf(
                    Color.argb((fog.alpha * intensity).toInt(), 100, 150, 200),
                    Color.argb(0, 100, 150, 200)
                ),
                floatArrayOf(0f, 1f),
                Shader.TileMode.CLAMP
            )
            fogPaint.shader = gradient
            canvas.drawCircle(fog.x, fog.y, fog.size, fogPaint)
        }
    }

    fun renderLightning(canvas: Canvas) {
        if (random.nextFloat() > 0.005f) return // Rare flash
        
        val flashPaint = Paint().apply {
            color = Color.argb(30, 200, 220, 255)
        }
        canvas.drawRect(0f, 0f, width.toFloat(), height.toFloat(), flashPaint)
        
        // Draw bolt
        val boltPaint = Paint().apply {
            color = Color.argb(200, 200, 220, 255)
            strokeWidth = 3f
            maskFilter = BlurMaskFilter(10f, BlurMaskFilter.Blur.NORMAL)
        }
        
        var x = random.nextFloat() * width
        var y = 0f
        while (y < height) {
            val nextX = x + (random.nextFloat() - 0.5f) * 100
            val nextY = y + 20f + random.nextFloat() * 40f
            canvas.drawLine(x, y, nextX, nextY, boltPaint)
            x = nextX
            y = nextY
        }
    }

    fun renderGlow(canvas: Canvas, x: Float, y: Float) {
        if (forceStrength <= 0) return
        
        val gradient = RadialGradient(
            x, y, forceRadius,
            intArrayOf(
                Color.argb((forceStrength * 100).toInt(), 0, 245, 255),
                Color.argb((forceStrength * 50).toInt(), 0, 200, 255),
                Color.argb(0, 0, 150, 255)
            ),
            floatArrayOf(0f, 0.5f, 1f),
            Shader.TileMode.CLAMP
        )
        glowPaint.shader = gradient
        canvas.drawCircle(x, y, forceRadius, glowPaint)
        forceStrength *= 0.95f // Decay
    }

    fun applyTouchForce(x: Float, y: Float, radius: Float = 100f) {
        forceX = x
        forceY = y
        forceRadius = radius
        forceStrength = 1f
    }

    fun setCharging(isCharging: Boolean) {
        this.isCharging = isCharging
    }

    fun renderChargingEffect(canvas: Canvas) {
        if (!isCharging) return
        chargePulse = (chargePulse + 0.02f) % (2 * PI).toFloat()
        val alpha = (sin(chargePulse) * 30 + 30).toInt().coerceIn(0, 60)
        
        val chargePaint = Paint().apply {
            shader = LinearGradient(
                0f, height.toFloat(), 0f, height - 200f,
                intArrayOf(
                    Color.argb(alpha, 0, 245, 255),
                    Color.argb(0, 0, 245, 255)
                ),
                floatArrayOf(0f, 1f),
                Shader.TileMode.CLAMP
            )
        }
        canvas.drawRect(0f, height - 200f, width.toFloat(), height.toFloat(), chargePaint)
    }

    fun release() {
        rainDrops.clear()
        snowFlakes.clear()
        fogParticles.clear()
    }
}
