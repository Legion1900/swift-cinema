package com.legion1900.swiftcore.network

import com.readdle.codegen.anotation.SwiftReference

@SwiftReference
class TMDBMovieService private constructor(){

    private var nativePointer: Long = 0
    external fun release()

    companion object {

        @JvmStatic
        external fun init(
            networkClient: NetworkClient
        ): TMDBMovieService
    }
}
