package com.legion1900.swiftcore.storage

import android.content.Context
import com.readdle.codegen.anotation.SwiftCallbackFunc
import com.readdle.codegen.anotation.SwiftDelegate

@SwiftDelegate(protocols = ["DbPathProvider"])
interface AndroidDbPathProvider {

    @SwiftCallbackFunc("getPathForDb(withName:)")
    fun getPathForDb(dbName: String): String

    companion object {

        fun create(ctx: Context): AndroidDbPathProvider {
            return object : AndroidDbPathProvider {
                override fun getPathForDb(dbName: String): String {
                    return ctx.getDatabasePath(dbName).absolutePath
                }
            }
        }
    }
}
