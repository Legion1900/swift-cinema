package com.legion1900.swiftcinema

import android.app.Application
import com.readdle.codegen.anotation.JavaSwift
import org.koin.android.ext.koin.androidContext
import org.koin.core.context.GlobalContext.startKoin

class SwiftCinemaApp : Application() {

    init {
        System.loadLibrary("CinemaCore")
        JavaSwift.init()
    }

    override fun onCreate() {
        super.onCreate()

        startKoin {
            androidContext(this@SwiftCinemaApp)
        }
    }
}
