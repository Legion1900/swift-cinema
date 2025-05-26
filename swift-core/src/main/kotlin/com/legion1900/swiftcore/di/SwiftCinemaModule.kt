package com.legion1900.swiftcore.di

import com.legion1900.swiftcore.ConfigProvider
import com.legion1900.swiftcore.MovieProvider
import com.legion1900.swiftcore.network.AndroidApiKeyProvider
import com.legion1900.swiftcore.network.TMDBMovieService
import com.legion1900.swiftcore.network.NetworkClient
import com.legion1900.swiftcore.utils.AndroidLogger
import org.koin.dsl.module

val swiftCinemaModule = module {
    single { AndroidLogger.DEFAULT }
    single { AndroidApiKeyProvider.DEFAULT }

    single {
        NetworkClient.init(
            baseUrl = "https://api.themoviedb.org",
            apiKeyProvider = get()
        ).apply {
            setLogger(get())
        }
    }

    single { TMDBMovieService.init(get()) }
    single { MovieProvider.init(get(), get(), get()) }
    single { ConfigProvider.init(get(), get()) }
}
