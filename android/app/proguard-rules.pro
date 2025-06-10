# Flutter core rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# AndroidX core rules (explicitly keep constructors)
-keep class androidx.** { *; }
-keep interface androidx.** { *; }
-keepclassmembers class * {
    void <init>();
}

# AndroidX Window Management (explicitly keep constructors for R8 compatibility)
-keep class androidx.window.extensions.** {
    public <init>();
    void <init>();
}
-keep class androidx.window.layout.adapter.extensions.** {
    public <init>();
    void <init>();
}
-keep class androidx.window.sidecar.** {
    public <init>();
    void <init>();
}

# Camera and related plugins
-keep class androidx.camera.** { *; }

# Audio/Bluetooth plugins
-keep class flutter_blue_plus.** { *; }
-keep class just_audio.** { *; }
-keep class flutter_sound.** { *; }

# Play Core and SplitCompat
-keep class com.google.android.play.core.splitcompat.** { *; }
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }

# Flutter Android embedding (critical for deferred components)
-keep class io.flutter.embedding.android.** { *; }
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }

# Reflection and native methods
-keepattributes Signature,InnerClasses,EnclosingMethod
-keepclasseswithmembernames class * {
    native <methods>;
}