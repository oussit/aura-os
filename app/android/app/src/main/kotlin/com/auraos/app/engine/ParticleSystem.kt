
package com.auraos.app.engine

import android.graphics.*
import kotlin.math.*
import kotlin.random.Random

class ParticleSystem(private val maxParticles: Int = 200) {
    
    private data class Particle(
        var x: Float, var y: Float,
        var vx: Float, var vy: Float,
        var size: Float, var alpha: Float,
        var color: Int, var life: Float
    )
    
    private val particles = mutableListOf<Particle>()
    private val random = Random.Default
    private var width = 0
    private var height = 0
    
    private val paint = Paint().apply {
        isAntiAlias = true
        xfermode = PorterDuffXfermode(PorterDuff.Mode.SCREEN)
    }
    
    fun resize(w: Int, h: Int) {
        width = w
        height = h
    }
    
    fun addBurst(x: Float, y: Float, count: Int = 10) {
        repeat(count) {
            if (particles.size >= maxParticles) {
                particles.removeAt(0)
            }
            val angle = random.nextFloat() * 2 * PI.toFloat()
            val speed = 2f + random.nextFloat() * 8f
            particles.add(Particle(
                x = x, y = y,
                vx = cos(angle) * speed,
                vy = sin(angle) * speed,
                size = 2f + random.nextFloat() * 4f,
                alpha = 0.5f + random.nextFloat() * 0.5f,
                color = Color.argb(255, 
                    random.nextInt(100, 255),
                    random.nextInt(200, 255),
                    255
                ),
                life = 1f
            ))
        }
    }
    
    fun updateAndDraw(canvas: Canvas) {
        val iterator = particles.iterator()
        while (iterator.hasNext()) {
            val p = iterator.next()
            
            // Physics update
            p.x += p.vx
            p.y += p.vy
            p.vy += 0.05f // gravity
            p.vx *= 0.99f // friction
            p.life -= 0.015f
            p.alpha = p.life
            
            if (p.life <= 0 || p.x < -50 || p.x > width + 50 || p.y > height + 50) {
                iterator.remove()
                continue
            }
            
            // Draw with glow
            paint.color = p.color
            paint.alpha = (p.alpha * 255).toInt().coerceIn(0, 255)
            paint.maskFilter = BlurMaskFilter(p.size * 2, BlurMaskFilter.Blur.NORMAL)
            canvas.drawCircle(p.x, p.y, p.size, paint)
            
            // Core
            paint.maskFilter = null
            paint.alpha = 255
            canvas.drawCircle(p.x, p.y, p.size * 0.5f, paint)
        }
    }
}
