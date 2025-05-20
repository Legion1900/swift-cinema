package org.legion1900.swift_cinema

interface Platform {
    val name: String
}

expect fun getPlatform(): Platform