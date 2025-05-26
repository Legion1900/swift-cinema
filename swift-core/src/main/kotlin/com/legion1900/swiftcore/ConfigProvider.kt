package com.legion1900.swiftcore

import com.legion1900.swiftcore.network.TMDBMovieService
import com.legion1900.swiftcore.utils.AndroidLogger
import com.readdle.codegen.anotation.SwiftFunc
import com.readdle.codegen.anotation.SwiftReference

@SwiftReference
class ConfigProvider private constructor() {

    private var nativePointer: Long = 0

    external fun release()

    companion object {
        @JvmStatic
        @SwiftFunc("init(forMovieService:logger:)")
        external fun init(service: TMDBMovieService, logger: AndroidLogger): ConfigProvider
    }
}
