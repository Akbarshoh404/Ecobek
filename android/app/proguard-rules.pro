# Keep TensorFlow Lite GPU classes
-keep class org.tensorflow.lite.gpu.** { *; }
-keep class org.tensorflow.lite.gpu.GpuDelegateFactory** { *; }
-keep class org.tensorflow.lite.gpu.GpuDelegateFactory$Options** { *; }

# General TFLite keep rules
-keep class org.tensorflow.lite.** { *; }
-dontwarn org.tensorflow.lite.**

# Suppress missing class warnings if needed (temporary)
-ignorewarnings