import com.readdle.android.swift.gradle.SwiftAndroidPluginExtension
import com.readdle.android.swift.gradle.SwiftAndroidPluginExtension.SwiftFlags

plugins {
    alias(libs.plugins.android.library)
    alias(libs.plugins.kotlin.android)
    alias(libs.plugins.readdle.swift)
    alias(libs.plugins.kotlin.kapt)
}

android {
    namespace = "com.legion1900.swift_core"
    compileSdk = 35
    ndkVersion = "25.2.9519653"

    defaultConfig {
        javaCompileOptions {
            annotationProcessorOptions {
                arguments["com.readdle.codegen.package"] = """{
                   "moduleName": "SwiftCoreGenerated",
                   "importPackages": ["JavaCoder", "SwiftCore"]
               }
               """
            }
        }
    }

    defaultConfig {
        minSdk = 24

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
        consumerProguardFiles("consumer-rules.pro")

        ndk {
            abiFilters += "arm64-v8a"
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }

        debug {
            isJniDebuggable = true
        }
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
    kotlinOptions {
        jvmTarget = "11"
    }
}

swift {
    useKapt = true
    cleanEnabled = false
    swiftLintEnabled = false
    apiLevel = 24

    debug(
        closureOf<SwiftFlags> {
            extraBuildFlags(
                "-Xswiftc", "-DDEBUG",
                "-Xswiftc", "-DDEBUG_BUILD",
                "-Xlinker", "--build-id",
            )
        }
    )

    release(
        closureOf<SwiftFlags> {
            val flags = arrayOf(
                "-Xswiftc", "-g",
                "-Xswiftc", "-DHIDE_ERROR_JAVA_BRIDGEABLE",
                "-Xlinker", "--build-id",
            )

            extraBuildFlags(*flags)
        }
    )
}

dependencies {

    implementation(libs.androidx.core.ktx)
    implementation(libs.androidx.appcompat)
    implementation(libs.material)

    kapt(libs.swift.codegen)
    implementation(libs.swift.codegen.annotations)

    testImplementation(libs.junit)
    androidTestImplementation(libs.androidx.junit)
    androidTestImplementation(libs.androidx.espresso.core)
}