package com.legion1900.swiftcore.utils

import android.util.Log
import com.readdle.codegen.anotation.SwiftCallbackFunc
import com.readdle.codegen.anotation.SwiftDelegate

@SwiftDelegate(protocols = ["Logger"])
interface AndroidLogger {

    @SwiftCallbackFunc("log(_:withTag:)")
    fun log(message: String, tag: String)

    companion object {

        val DEFAULT by lazy {
            object : AndroidLogger {
                override fun log(message: String, tag: String) {
                    Log.d(tag, message)
                }
            }
        }
    }
}
