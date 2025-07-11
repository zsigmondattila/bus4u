package com.bus4u.pos.domain.viewmodel

import android.app.Application
import android.util.Log
import android.widget.Toast
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.bus4u.pos.util.StorageUtils
import com.bus4u.pos.util.ApiClient
import kotlinx.coroutines.launch
import retrofit2.HttpException

class LoginViewModel(application: Application) : AndroidViewModel(application) {

    fun login(email: String, password: String, onSuccess: () -> Unit, onError: (String) -> Unit) {
        viewModelScope.launch {
            try {
                val response = ApiClient.apiService.login(email, password)
                if (response.isSuccessful) {
                    val token = response.headers()["authorization"] ?: ""
                    val companyUid = response.body()?.data?.company_uid ?: ""

                    val context = getApplication<Application>().applicationContext
                    StorageUtils.saveToken(context, token)
                    StorageUtils.saveCompanyUid(context, companyUid)
                    onSuccess()
                } else {
                    onError("Error during login: ${response.message()}")
                }
            } catch (e: HttpException) {
                onError("Network error: ${e.message}")
            } catch (e: Exception) {
                Log.e("LoginViewModel", "Login error", e)
                onError("Error: ${e.localizedMessage}")
            }
        }
    }
}
