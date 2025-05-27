package com.legion1900.swiftcinema.di

import com.legion1900.swiftcinema.MoviesListViewModel
import org.koin.core.module.dsl.viewModelOf
import org.koin.dsl.module

val appModule = module {

    viewModelOf(::MoviesListViewModel)
}
