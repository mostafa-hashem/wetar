# Keep Wetar platform channels and AudioService classes intact under R8
-keep class com.wetar.** { *; }
-keep class com.ryanheise.audioservice.** { *; }
-keep class com.ryanheise.just_audio.** { *; }
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}
-dontwarn com.google.errorprone.annotations.**
-dontwarn javax.annotation.**
