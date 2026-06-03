# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.

# Keep Flutter engine
-keep class io.flutter.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.util.** { *; }

# Keep Kotlin
-keep class kotlin.** { *; }

# Keep JSON models
-keep class com.auraos.app.** { *; }

# Keep Firebase
-keep class com.google.firebase.** { *; }

# Keep AdMob
-keep class com.google.android.gms.ads.** { *; }

# Keep Gson/Serialization
-keepattributes Signature
-keepattributes *Annotation*
-keep class * implements java.io.Serializable { *; }

# Keep data classes
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}
