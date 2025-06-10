package com.bus4u.pos.util

import android.content.Context
import android.content.SharedPreferences

object StorageUtils {
    private const val PREF_NAME = "bus4u_prefs"
    private const val KEY_TOKEN = "token"
    private const val KEY_COMPANY_UID = "company_uid"

    private fun getPrefs(context: Context): SharedPreferences {
        return context.getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE)
    }

    fun saveToken(context: Context, token: String) {
        getPrefs(context).edit().putString(KEY_TOKEN, token).apply()
    }

    fun getToken(context: Context): String? {
        return getPrefs(context).getString(KEY_TOKEN, null)
    }

    fun saveCompanyUid(context: Context, companyUid: String) {
        getPrefs(context).edit().putString(KEY_COMPANY_UID, companyUid).apply()
    }

    fun getCompanyUid(context: Context): String? {
        return getPrefs(context).getString(KEY_COMPANY_UID, null)
    }
}
