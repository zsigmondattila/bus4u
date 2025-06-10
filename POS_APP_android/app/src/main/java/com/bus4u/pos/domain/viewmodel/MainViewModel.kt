package com.bus4u.pos.domain.viewmodel

import android.util.Log
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.bus4u.pos.data.Bus
import com.bus4u.pos.data.ChangeLocationRequest
import com.bus4u.pos.data.Route
import com.bus4u.pos.data.RoutesResponse
import com.bus4u.pos.util.ApiService
import kotlinx.coroutines.launch
import retrofit2.Response

class MainViewModel(private val apiService: ApiService) : ViewModel() {

    private var cachedRoutes: List<Route> = emptyList()

    fun fetchCompanyData(
        token: String,
        companyUid: String,
        onSuccess: (List<Bus>, List<Route>) -> Unit,
        onError: (String) -> Unit
    ) {
        viewModelScope.launch {
            try {
                val busesResponse = apiService.getBusesOfCompany(token, companyUid)
                val routesResponse = apiService.getRoutesOfCompany(token, companyUid)

                if (busesResponse.isSuccessful && routesResponse.isSuccessful) {
                    val buses: List<Bus> = busesResponse.body() ?: emptyList()
                    val routes: List<Route> = routesResponse.body()?.routes ?: emptyList()

                    cachedRoutes = routes

                    onSuccess(buses, routes)
                } else {
                    onError("Failed to fetch data: ${busesResponse.code()} - ${routesResponse.code()}")
                }
            } catch (e: Exception) {
                onError("Network error: ${e.localizedMessage ?: e.message}")
            }
        }
    }

    fun setBusTracked(token: String, licensePlate: String, onResult: (Boolean, String?) -> Unit) {
        viewModelScope.launch {
            try {
                val response = apiService.setBusTracked(token, licensePlate)
                if (response.isSuccessful) {
                    onResult(true, null)
                } else {
                    onResult(false, "Error: ${response.code()}")
                }
            } catch (e: Exception) {
                onResult(false, "Network error: ${e.localizedMessage ?: e.message}")
            }
        }
    }

    fun setBusUntracked(token: String, licensePlate: String, onResult: (Boolean, String?) -> Unit) {
        viewModelScope.launch {
            try {
                val response = apiService.setBusUntracked(token, licensePlate)
                if (response.isSuccessful) {
                    onResult(true, null)
                } else {
                    onResult(false, "Error: ${response.code()}")
                }
            } catch (e: Exception) {
                onResult(false, "Network error: ${e.localizedMessage ?: e.message}")
            }
        }
    }

    fun sendBusLocation(
        token: String,
        licensePlate: String,
        routeUid: String,
        latitude: Double,
        longitude: Double
    ) {
        viewModelScope.launch {
            try {
                val request = ChangeLocationRequest(
                    license_plate = licensePlate,
                    route_uid = routeUid,
                    latitude = latitude,
                    longitude = longitude
                )
                val response = apiService.changeBusLocation("Bearer $token", request)
                if (response.isSuccessful) {
                    Log.d("MainViewModel", "Location sent successfully")
                } else {
                    Log.e("MainViewModel", "Error sending location")
                }
            } catch (e: Exception) {
                Log.e("MainViewModel", "Error $e")
            }
        }
    }

    fun getRouteByName(name: String): Route? {
        return cachedRoutes.find { it.name == name }
    }
}
