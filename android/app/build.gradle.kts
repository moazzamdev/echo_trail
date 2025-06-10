val kotlin_version by extra("1.9.22")

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.echo_trail"
    compileSdk = 35

    defaultConfig {
        applicationId = "com.echo_trail"
        minSdk = 24
        targetSdk = 35
        versionCode = 1
        versionName = "1.0"
        multiDexEnabled = true
    }

    lint {
        abortOnError = false
        checkReleaseBuilds = false
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

repositories {
    google()
    mavenCentral()
    maven { url = uri("https://storage.googleapis.com/download.flutter.io") }
}

dependencies {
    // AndroidX Window Management (for foldable/split-screen support)
    implementation("androidx.window:window:1.4.0")

    // Play Core (for deferred components and dynamic features)
    implementation("com.google.android.play:core:1.10.3")
    implementation("androidx.core:core-ktx:1.16.0")
    implementation("androidx.multidex:multidex:2.0.1")
    implementation("org.jetbrains.kotlin:kotlin-stdlib:$kotlin_version")
    implementation("com.google.android.material:material:1.12.0")
    // Use the correct version if intended
    implementation("dev.sasikanth:material-color-utilities:1.0.0-alpha01")
    implementation("androidx.appcompat:appcompat:1.7.0")
    implementation("androidx.activity:activity-ktx:1.9.0")
    implementation("androidx.fragment:fragment-ktx:1.8.0")
    implementation("androidx.annotation:annotation:1.7.1")

}

configurations.all {
    resolutionStrategy {
        force("com.google.android.material:material:1.12.0")
    }
}