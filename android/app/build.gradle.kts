plugins {
    id("com.android.application")
    // El plugin de Gradle de Flutter debe aplicarse después de los de Android y Kotlin.
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.agbot.remotecontrol"
    compileSdk = 37
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Especifica un identificador único para tu aplicación; consulta el enlace siguiente.
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.agbot.remotecontrol"
        // Puedes adaptar los siguientes valores a las necesidades de tu aplicación.
        // Consulta más información en https://flutter.dev/to/review-gradle-config.
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Usa el código de versión de pubspec.yaml. Con APK divididos, Flutter añade
        // automáticamente 1000 * ABI_VERSION; consulta el enlace siguiente.
        // Puedes forzar el valor de versionCode pasando la opción
        // `-P force-version-code-ignoring-abi=true` durante la compilación.
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Añade tu propia configuración de firma para la compilación de producción.
            // Por ahora se firma con las claves de depuración para que funcione `flutter run --release`.
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
