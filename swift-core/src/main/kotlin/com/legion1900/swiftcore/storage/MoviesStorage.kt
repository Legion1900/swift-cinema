package com.legion1900.swiftcore.storage

import com.legion1900.swiftcore.utils.AndroidLogger
import com.readdle.codegen.anotation.SwiftFunc
import com.readdle.codegen.anotation.SwiftReference

@SwiftReference
class MoviesStorage private constructor() {

    private var nativePointer: Long = 0

    external fun release()

    companion object {
        @JvmStatic
        @SwiftFunc("init(dbPathprovider:logger:)")
        external fun init(pathProvider: AndroidDbPathProvider, logger: AndroidLogger): MoviesStorage
    }
}
