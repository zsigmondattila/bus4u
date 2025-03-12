package com.bus4u.pos

import android.content.Context
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.EditText
import androidx.appcompat.app.AlertDialog
import androidx.fragment.app.Fragment
import okhttp3.*
import org.json.JSONObject
import java.io.IOException

class LoginFragment : Fragment() {

    private val client = OkHttpClient()

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        return inflater.inflate(R.layout.fragment_login, container, false)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        val emailEditText = view.findViewById<EditText>(R.id.emailEditText)
        val passwordEditText = view.findViewById<EditText>(R.id.passwordEditText)
        val loginButton = view.findViewById<Button>(R.id.loginButton)

        loginButton.setOnClickListener {
            val email = emailEditText.text.toString()
            val password = passwordEditText.text.toString()
            loginUser(email, password)
        }
    }

    private fun loginUser(email: String, password: String) {
        val formBody = FormBody.Builder()
            .add("email", email)
            .add("password", password)
            .build()

        val request = Request.Builder()
            .url("https://api.bus4u.online/admin/sign_in")
            .post(formBody)
            .build()

        client.newCall(request).enqueue(object : Callback {
            override fun onFailure(call: Call, e: IOException) {
                activity?.runOnUiThread {
                    AlertDialog.Builder(requireContext())
                        .setTitle("POS")
                        .setMessage("Network error: ${e.message}")
                        .setPositiveButton("OK") { dialog, _ -> dialog.dismiss() }
                        .show()
                }
            }

            override fun onResponse(call: Call, response: Response) {
                val responseBody = response.body?.string()
                if (response.isSuccessful && responseBody != null) {
                    val json = JSONObject(responseBody)
                    val data = json.getJSONObject("data")
                    val companyUid = data.optString("company_uid", "")
                    val token = response.header("authorization") ?: ""

                    // Token és company_uid mentése SharedPreferences-be
                    val prefs = requireContext().getSharedPreferences("myPrefs", Context.MODE_PRIVATE)
                    with(prefs.edit()) {
                        putString("token", token)
                        putString("company", companyUid)
                        apply()
                    }

                    activity?.runOnUiThread {
                        // Átlépés a GPSFragment-re
                        activity?.supportFragmentManager?.beginTransaction()
                            ?.replace(R.id.fragment_container, GPSFragment())
                            ?.commit()
                    }
                } else {
                    activity?.runOnUiThread {
                        AlertDialog.Builder(requireContext())
                            .setTitle("POS")
                            .setMessage("Incorrect e-mail or password")
                            .setPositiveButton("OK") { dialog, _ -> dialog.dismiss() }
                            .show()
                    }
                }
            }
        })
    }
}

