package com.bus4u.pos.data

data class TicketValidationResult(
    val success: String? = null,
    val error: String? = null
)

data class RoutesResponse(
    val routes: List<Route>
)

data class Route(
    val route_uid: String,
    val company_uid: String,
    val name: String,
    val nr_of_stations: Int,
    val basic_fare: String,
    val created_at: String,
    val updated_at: String
)

data class ChangeLocationRequest(
    val license_plate: String,
    val route_uid: String,
    val latitude: Double,
    val longitude: Double
)

data class Bus(
    val bus_uid: String,
    val company_uid: String,
    val license_plate: String,
    val brand: String,
    val manufacturing_year: Int,
    val capacity: Int,
    val road_tax: String,
    val insurance: String,
    val technical_exam: String,
    val tracked: Boolean?,
    val latitude: Double?,
    val longitude: Double?,
    val current_route_uid: String?,
    val created_at: String,
    val updated_at: String
)

data class LoginResponse(
    val data: LoginData?
)

data class LoginData(
    val company_uid: String?
)

