# Flutter
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.app.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Google Maps
-keep class com.google.android.gms.maps.** { *; }
-dontwarn com.google.android.gms.maps.**

# Google Wallet
-keep class com.google.android.gms.wallet.** { *; }
-dontwarn com.google.android.gms.wallet.**

# WeChat SDK
-keep class com.tencent.mm.opensdk.** { *; }
-dontwarn com.tencent.mm.opensdk.**

# Card.io SDK
-keep class io.card.** { *; }
-dontwarn io.card.**
# Required to prevent Flutter Play Core / SplitInstallManager crashes
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# Stripe push provisioning
-keep class com.stripe.android.pushProvisioning.** { *; }
-dontwarn com.stripe.android.pushProvisioning.**

# Keep Razorpay analytics classes
-keep class proguard.annotation.** { *; }
-dontwarn proguard.annotation.**

# Prevent removal of Flutter deferred component handling
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }

# General keep rules for reflection-heavy code
-keepclassmembers class * {
    public <init>(...);
}

# Aggressive optimization for smaller APK
-optimizations !code/simplification/arithmetic,!code/simplification/cast,!field/*,!class/merging/*
-optimizationpasses 5
-allowaccessmodification

# Remove unused classes and methods
-dontwarn **
-keep class com.jippymart.customer.MainActivity { *; }

# Remove logging
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}
