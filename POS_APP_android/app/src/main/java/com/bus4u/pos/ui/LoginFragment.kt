package com.bus4u.pos.ui

import android.os.Bundle
import android.view.View
import android.widget.Button
import android.widget.EditText
import android.widget.Toast
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import androidx.navigation.fragment.findNavController
import com.bus4u.pos.R
import com.bus4u.pos.domain.viewmodel.LoginViewModel
import com.bus4u.pos.util.ApiClient

class LoginFragment : Fragment(R.layout.fragment_login) {

    private val viewModel: LoginViewModel by viewModels()

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        val emailEditText = view.findViewById<EditText>(R.id.emailEditText)
        val passwordEditText = view.findViewById<EditText>(R.id.passwordEditText)
        val loginButton = view.findViewById<Button>(R.id.loginButton)
        val loginProgressBar = view.findViewById<View>(R.id.loginProgressBar)

        val hiddenButton = view.findViewById<Button>(R.id.hiddenButton)
        hiddenButton.setOnClickListener {
            showChangeBaseUrlDialog()
        }

        loginButton.setOnClickListener {
            val email = emailEditText.text.toString().trim()
            val password = passwordEditText.text.toString()

            if (email.isEmpty() || password.isEmpty()) {
                Toast.makeText(requireContext(), "All fields are mandatory", Toast.LENGTH_SHORT).show()
                return@setOnClickListener
            }

            loginButton.text = ""
            loginButton.isEnabled = false
            loginProgressBar.visibility = View.VISIBLE

            viewModel.login(
                email,
                password,
                onSuccess = {
                    loginProgressBar.visibility = View.GONE
                    loginButton.isEnabled = true
                    loginButton.text = "Log in"
                    findNavController().navigate(LoginFragmentDirections.actionLoginFragmentToMainFragment())
                },
                onError = { errorMessage ->
                    loginProgressBar.visibility = View.GONE
                    loginButton.isEnabled = true
                    loginButton.text = "Log in"
                    Toast.makeText(requireContext(), errorMessage, Toast.LENGTH_LONG).show()
                }
            )
        }
    }

    private fun showChangeBaseUrlDialog() {
        val editText = EditText(requireContext()).apply {
            hint = "Enter base URL"
            inputType = android.text.InputType.TYPE_TEXT_VARIATION_URI
            setText(ApiClient.baseUrl)  // jelenlegi base URL előtöltése
        }

        androidx.appcompat.app.AlertDialog.Builder(requireContext())
            .setTitle("Change Base URL")
            .setView(editText)
            .setPositiveButton("Save") { dialog, _ ->
                val newUrl = editText.text.toString().trim()
                if (newUrl.isNotBlank()) {
                    ApiClient.setBaseUrl(newUrl)
                    Toast.makeText(requireContext(), "Base URL updated", Toast.LENGTH_SHORT).show()
                } else {
                    Toast.makeText(requireContext(), "Invalid URL", Toast.LENGTH_SHORT).show()
                }
                dialog.dismiss()
            }
            .setNegativeButton("Cancel") { dialog, _ ->
                dialog.dismiss()
            }
            .show()
    }
}
