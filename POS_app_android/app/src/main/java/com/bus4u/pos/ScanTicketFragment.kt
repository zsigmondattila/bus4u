package com.bus4u.pos

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import androidx.appcompat.app.AlertDialog
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import com.google.zxing.integration.android.IntentIntegrator
import okhttp3.*
import java.io.IOException

class ScanTicketFragment : Fragment() {

    private lateinit var scannedTicketTextView: TextView
    private val client = OkHttpClient()

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        return inflater.inflate(R.layout.fragment_scan_ticket, container, false)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        scannedTicketTextView = view.findViewById(R.id.scannedTicketTextView)
        // Indítsuk el a barcode olvasót
        startBarcodeScanner()
    }

    private fun startBarcodeScanner() {
        IntentIntegrator.forSupportFragment(this).apply {
            setDesiredBarcodeFormats(IntentIntegrator.ALL_CODE_TYPES)
            setPrompt("Scan a ticket")
            setCameraId(0)
            setBeepEnabled(true)
            setBarcodeImageEnabled(false)
            initiateScan()
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        val result = IntentIntegrator.parseActivityResult(requestCode, resultCode, data)
        if (result != null) {
            val scannedTicket = result.contents ?: ""
            scannedTicketTextView.text = scannedTicket
            // Küldjük el a jegyet a szervernek
            sendScannedTicket(scannedTicket)
        } else {
            super.onActivityResult(requestCode, resultCode, data)
        }
    }

    private fun sendScannedTicket(ticketUid: String) {
        val prefs = requireContext().getSharedPreferences("myPrefs", Context.MODE_PRIVATE)
        val token = prefs.getString("token", "") ?: ""

        val formBody = FormBody.Builder()
            .add("ticket_uid", ticketUid)
            .build()

        val request = Request.Builder()
            .url("https://api.bus4u.online/v1/admin/use_ticket")
            .post(formBody)
            .header("Authorization", "Bearer $token")
            .header("Content-Type", "application/x-www-form-urlencoded")
            .build()

        client.newCall(request).enqueue(object : Callback {
            override fun onFailure(call: Call, e: IOException) {
                e.printStackTrace()
            }

            override fun onResponse(call: Call, response: Response) {
                val status = response.code
                val message = when (status) {
                    202 -> "Ticket successfully validated. Have a nice trip!"
                    422 -> "The scanned ticket is invalid or expired. Please contact the driver."
                    else -> "Server error, please contact the driver."
                }
                activity?.runOnUiThread {
                    showStatusDialog(message, status)
                }
            }
        })
    }

    private fun showStatusDialog(message: String, statusCode: Int) {
        val (backgroundColor, textColor) = if (statusCode == 202) {
            Pair(0xFFCDFCBF.toInt(), 0xFF000000.toInt())
        } else {
            Pair(0xFFFFB9B4.toInt(), 0xFF000000.toInt())
        }

        AlertDialog.Builder(requireContext())
            .setMessage(message)
            .setPositiveButton("OK") { dialog, _ ->
                dialog.dismiss()
                // Indítsuk újra az olvasást 5 mp múlva
                Handler(Looper.getMainLooper()).postDelayed({
                    startBarcodeScanner()
                }, 5000)
            }
            .create()
            .show()
    }
}
