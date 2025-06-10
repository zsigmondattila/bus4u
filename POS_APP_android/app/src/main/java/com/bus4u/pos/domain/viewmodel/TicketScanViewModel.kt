package com.bus4u.pos.domain.viewmodel

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.bus4u.pos.data.TicketValidationResult
import com.bus4u.pos.util.ApiService
import com.google.gson.Gson
import kotlinx.coroutines.launch
import retrofit2.HttpException
import retrofit2.Response
import java.io.IOException

class TicketScanViewModel(private val apiService: ApiService) : ViewModel() {

    private val _validationResult = MutableLiveData<TicketValidationResult>()
    val validationResult: LiveData<TicketValidationResult> = _validationResult

    fun validateTicket(token: String, qrCode: String) {
        viewModelScope.launch {
            try {
                val response: Response<TicketValidationResult> =
                    apiService.useTicket(token, qrCode)

                if (response.isSuccessful) {
                    _validationResult.postValue(response.body())
                } else {
                    val errorBody = response.errorBody()?.string()
                    val errorResponse = Gson().fromJson(errorBody, TicketValidationResult::class.java)
                    _validationResult.postValue(errorResponse)
                }
            }  catch (e: Exception) {
                _validationResult.postValue(TicketValidationResult(error = "Error: $e"))
            }
        }
    }
}
