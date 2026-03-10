plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // ✅ Ajouté pour Firebase
}

android {
    namespace = "com.u_go.app"
    compileSdk = 36
    ndkVersion = "28.1.13356709"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // ✅ Utilise un Application ID cohérent (doit correspondre à celui utilisé dans Firebase)
        applicationId = "com.u_go.app"
        // ⛳️ FIX: minSdk forcé à 23 pour satisfaire cloud_firestore
        minSdk = maxOf(23, flutter.minSdkVersion)

        // cible moderne (tu peux aussi garder flutter.targetSdkVersion si >= 33)
        targetSdk = maxOf(34, flutter.targetSdkVersion)
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // ✅ BoM (gère les versions compatibles automatiquement)
    implementation(platform("com.google.firebase:firebase-bom:34.0.0"))

    // ✅ Firebase SDKs que tu veux utiliser
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-auth")
    
    // Tu peux en ajouter d'autres ici : firestore, messaging, etc.
}
