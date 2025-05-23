package com.legion1900.swiftcore.network

import com.legion1900.swiftcore.utils.AndroidLogger
import com.readdle.codegen.anotation.SwiftFunc
import com.readdle.codegen.anotation.SwiftReference
import com.readdle.codegen.anotation.SwiftSetter

@SwiftReference
class NetworkClient private constructor() {

    private var nativePointer: Long = 0

    @SwiftSetter("logger")
    external fun setLogger(logger: AndroidLogger)

    external fun release()

    @SwiftFunc
    external fun testRequest()

    companion object {

        @JvmStatic
        external fun init(baseUrl: String, apiKeyProvider: AndroidApiKeyProvider): NetworkClient

        @JvmStatic
        external fun setupCertificates(certPath: String)
    }
}
