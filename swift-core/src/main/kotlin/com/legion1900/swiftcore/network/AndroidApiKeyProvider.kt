package com.legion1900.swiftcore.network

import com.legion1900.swiftcore.BuildConfig
import com.readdle.codegen.anotation.SwiftCallbackFunc
import com.readdle.codegen.anotation.SwiftDelegate

@SwiftDelegate(protocols = ["ApiKeyProvider"])
interface AndroidApiKeyProvider {

    @SwiftCallbackFunc
    fun getApiKey(): String

    companion object {
        val DEFAULT by lazy {
            object : AndroidApiKeyProvider {
                override fun getApiKey(): String {
                    return BuildConfig.API_KEY
                }
            }
        }
    }
}
