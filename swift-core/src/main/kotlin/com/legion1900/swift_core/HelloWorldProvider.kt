package com.legion1900.swift_core

import com.readdle.codegen.anotation.SwiftReference
import java.lang.annotation.Native

@SwiftReference
class HelloWorldProvider private constructor() {

    @Native
    private val nativePointer: Long = 0

    external fun helloWorld(): String

    external fun release()

    companion object {

        @JvmStatic
        external fun init(): HelloWorldProvider
    }
}
