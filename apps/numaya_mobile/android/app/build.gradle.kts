import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// PR-001: release builds are signed with the upload key described in android/key.properties
// (git-ignored; template in android/key.properties.example). Without it a release build stops
// with a clear error instead of quietly using the debug key. `-PnumayaAllowDebugSignedRelease=true`
// is the explicit, local-QA-only escape hatch; such an artifact must never be distributed.
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
val hasReleaseKey = keystorePropertiesFile.exists()
if (hasReleaseKey) {
    FileInputStream(keystorePropertiesFile).use { keystoreProperties.load(it) }
}
val allowDebugSignedRelease =
    (project.findProperty("numayaAllowDebugSignedRelease") as String?) == "true"

android {
    namespace = "com.numaya.numaya_mobile"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.numaya.numaya_mobile"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseKey) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            signingConfig = when {
                hasReleaseKey -> signingConfigs.getByName("release")
                allowDebugSignedRelease -> signingConfigs.getByName("debug")
                else -> null
            }
        }
    }
}

// Fail early and clearly when a release artifact is requested without a release key.
gradle.taskGraph.whenReady {
    val wantsRelease = allTasks.any { task ->
        task.project == project &&
            (task.name.startsWith("assemble") || task.name.startsWith("bundle") ||
                task.name.startsWith("package")) &&
            task.name.endsWith("Release")
    }
    if (wantsRelease && !hasReleaseKey && !allowDebugSignedRelease) {
        throw GradleException(
            "Release signing is not configured: create android/key.properties " +
                "(see android/key.properties.example) with the upload keystore. " +
                "For a local, never-distributed QA build only, pass " +
                "-PnumayaAllowDebugSignedRelease=true.",
        )
    }
    if (wantsRelease && !hasReleaseKey && allowDebugSignedRelease) {
        logger.warn("WARNING: release build signed with the DEBUG key (local QA only; do not distribute).")
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
