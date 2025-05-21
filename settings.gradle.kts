pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
        maven("https://plugins.gradle.org/m2/")
        maven("https://developer.huawei.com/repo/")
    }

    resolutionStrategy {
        // Workaround for the wrongly resolved plugin names
        // origin - https://stackoverflow.com/a/69645726/5039385
        // explanation - https://stackoverflow.com/a/71135974/5039385
        eachPlugin {
            if (requested.id.id.startsWith("com.readdle.android.swift")) {
                useModule("com.readdle.android.swift:gradle:${requested.version}")
            }
        }
    }
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.name = "SwiftCinema"
include(":app")
include(":swift-core")
