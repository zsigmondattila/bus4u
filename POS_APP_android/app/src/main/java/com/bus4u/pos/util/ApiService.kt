package com.bus4u.pos.util

import com.bus4u.pos.data.Bus
import com.bus4u.pos.data.ChangeLocationRequest
import com.bus4u.pos.data.LoginResponse
import com.bus4u.pos.data.RoutesResponse
import com.bus4u.pos.data.TicketValidationResult
import retrofit2.http.*
import retrofit2.Response

interface ApiService {

    @FormUrlEncoded
    @POST("v1/admin/use_ticket")
    suspend fun useTicket(
        @Header("Authorization") token: String,
        @Field("ticket_uid") ticketUid: String
    ): Response<TicketValidationResult>

    @POST("v1/admin/change_bus_location")
    suspend fun changeBusLocation(
        @Header("Authorization") token: String,
        @Body request: ChangeLocationRequest
    ): Response<Unit>


    @FormUrlEncoded
    @POST("v1/admin/set_a_bus_tracked")
    suspend fun setBusTracked(
        @Header("Authorization") token: String,
        @Field("license_plate") licensePlate: String
    ): Response<Unit>

    @FormUrlEncoded
    @POST("v1/admin/set_a_bus_untracked")
    suspend fun setBusUntracked(
        @Header("Authorization") token: String,
        @Field("license_plate") licensePlate: String
    ): Response<Unit>

    @GET("v1/admin/get_routes_of_a_company")
    suspend fun getRoutesOfCompany(
        @Header("Authorization") token: String,
        @Query("company_uid") companyUid: String
    ): Response<RoutesResponse>

    @GET("v1/admin/get_buses_of_a_company")
    suspend fun getBusesOfCompany(
        @Header("Authorization") token: String,
        @Query("company_uid") companyUid: String
    ): Response<List<Bus>>

    @FormUrlEncoded
    @POST("admin/sign_in")
    suspend fun login(
        @Field("email") email: String,
        @Field("password") password: String
    ): Response<LoginResponse>

}
