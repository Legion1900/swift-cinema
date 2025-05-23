package com.legion1900.swiftcinema

import android.app.Application
import com.legion1900.swiftcore.di.swiftCinemaModule
import com.legion1900.swiftcore.network.NetworkClient
import com.readdle.codegen.anotation.JavaSwift
import org.koin.android.ext.koin.androidContext
import org.koin.core.context.GlobalContext.startKoin
import java.io.File

class SwiftCinemaApp : Application() {

    init {
        System.loadLibrary("CinemaCore")
        JavaSwift.init()
    }

    override fun onCreate() {
        super.onCreate()

        setupKoin()
        setupSSL()
    }

    private fun setupKoin() {
        startKoin {
            androidContext(this@SwiftCinemaApp)
            modules(
                swiftCinemaModule
            )
        }
    }

    private fun setupSSL() {
        NetworkClient.setupCertificates(
            certPath = copyCertToAppFiles()
        )
    }

    private fun copyCertToAppFiles(): String {
        val certFile = File(dataDir.absolutePath, "cacert.pem")
        if (!certFile.exists()) {
            assets.open("cacert.pem").use { input ->
                certFile.outputStream().use { output ->
                    input.copyTo(output)
                }
            }
        }

        return certFile.absolutePath
    }
}
