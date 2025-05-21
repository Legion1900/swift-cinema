package com.legion1900.swiftcinema

import android.app.Application
import android.util.Log
import com.readdle.codegen.anotation.JavaSwift
import java.io.File

class SwiftCinemaApp : Application() {

    init {
        System.loadLibrary("CinemaCore")
        JavaSwift.init()
    }

    override fun onCreate() {
        super.onCreate()
        File(applicationContext.applicationInfo.nativeLibraryDir).list()
            .contentToString()
        Log.d("enigma", "${applicationContext.applicationInfo.nativeLibraryDir}")
        loadNativeLibs()
    }

    private fun loadNativeLibs() {
//        System.loadLibrary("Foundation")
//        System.loadLibrary("swiftCore")
//        JavaSwift.init()
    }
}
