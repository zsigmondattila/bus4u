package com.bus4u.pos.util

import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory

object ApiClient {
    var baseUrl: String = "https://api.bus4u.online"
        private set

    private var retrofit: Retrofit = createRetrofit(baseUrl)

    private fun createRetrofit(url: String): Retrofit {
        return Retrofit.Builder()
            .baseUrl(url)
            .addConverterFactory(GsonConverterFactory.create())
            .build()
    }

    val apiService: ApiService
        get() = retrofit.create(ApiService::class.java)

    fun setBaseUrl(newUrl: String) {
        if (newUrl != baseUrl) {
            baseUrl = newUrl
            retrofit = createRetrofit(baseUrl)
        }
    }
}