import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val secretProps = Properties()
val secretPropsFile = rootProject.file("secret.properties")
if (secretPropsFile.exists()) {
    secretPropsFile.inputStream().use { secretProps.load(it) }
}

fun secretProp(name: String): String = secretProps.getProperty(name) ?: ""

android {
    namespace = "com.mohaeng.app.mohaeng_app_service"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.mohaeng.app.mohaeng_app_service"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        resValue("string", "client_id", secretProp("NAVER_CLIENT_ID"))
        resValue("string", "client_secret", secretProp("NAVER_CLIENT_SECRET"))
        resValue("string", "client_name", secretProp("NAVER_CLIENT_NAME"))
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
