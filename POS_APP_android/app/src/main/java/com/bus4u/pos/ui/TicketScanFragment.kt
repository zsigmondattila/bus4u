package com.bus4u.pos.ui

import android.Manifest
import android.content.pm.PackageManager
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.EditText
import android.widget.ImageView
import android.widget.TextView
import androidx.activity.OnBackPressedCallback
import androidx.annotation.OptIn
import androidx.appcompat.app.AlertDialog
import androidx.camera.core.CameraSelector
import androidx.camera.core.ExperimentalGetImage
import androidx.camera.core.ImageAnalysis
import androidx.camera.core.ImageProxy
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.camera.view.PreviewView
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.fragment.app.Fragment
import androidx.lifecycle.ViewModelProvider
import com.bus4u.pos.MainActivity
import com.bus4u.pos.R
import com.bus4u.pos.domain.viewmodel.TicketScanViewModel
import com.google.mlkit.vision.barcode.common.Barcode
import com.google.mlkit.vision.barcode.BarcodeScannerOptions
import com.google.mlkit.vision.barcode.BarcodeScanning
import com.google.mlkit.vision.common.InputImage
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors
import com.bus4u.pos.domain.viewmodel.TicketScanViewModelFactory
import com.bus4u.pos.util.ApiClient
import com.bus4u.pos.util.StorageUtils

class TicketScanFragment : Fragment() {

    private lateinit var viewModel: TicketScanViewModel
    private lateinit var previewView: PreviewView
    private lateinit var validationStatusTextView: TextView
    private lateinit var exitButton: Button
    private lateinit var rootLayout: View
    private lateinit var statusIcon: ImageView
    private lateinit var onBackPressedCallback: OnBackPressedCallback

    private var cameraExecutor: ExecutorService? = null

    private var isProcessing = false

    companion object {
        private const val CAMERA_PERMISSION_REQUEST_CODE = 1001
    }

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        return inflater.inflate(R.layout.fragment_ticket_scan, container, false)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        val apiService = ApiClient.apiService
        val factory = TicketScanViewModelFactory(apiService)

        viewModel = ViewModelProvider(this, factory)[TicketScanViewModel::class.java]

        previewView = view.findViewById(R.id.previewView)
        validationStatusTextView = view.findViewById(R.id.validationStatusTextView)
        exitButton = view.findViewById(R.id.exitButton)
        rootLayout = view.findViewById(R.id.rootLayout)
        statusIcon = view.findViewById(R.id.statusIconImageView)

        exitButton.setOnClickListener {
            showPinDialog()
        }

        onBackPressedCallback = object : OnBackPressedCallback(true) {
            override fun handleOnBackPressed() {
                showPinDialog()
            }
        }
        requireActivity().onBackPressedDispatcher.addCallback(viewLifecycleOwner, onBackPressedCallback)

        if (allPermissionsGranted()) {
            startCamera()
        } else {
            ActivityCompat.requestPermissions(requireActivity(),
                arrayOf(Manifest.permission.CAMERA),
                CAMERA_PERMISSION_REQUEST_CODE)
        }

        cameraExecutor = Executors.newSingleThreadExecutor()

        observeViewModel()
    }

    private fun allPermissionsGranted() = ContextCompat.checkSelfPermission(
        requireContext(), Manifest.permission.CAMERA) == PackageManager.PERMISSION_GRANTED

    private fun startCamera() {
        val cameraProviderFuture = ProcessCameraProvider.getInstance(requireContext())
        cameraProviderFuture.addListener({
            val cameraProvider = cameraProviderFuture.get()

            val preview = androidx.camera.core.Preview.Builder()
                .build()
                .also {
                    it.setSurfaceProvider(previewView.surfaceProvider)
                }

            val scannerOptions = BarcodeScannerOptions.Builder()
                .setBarcodeFormats(Barcode.FORMAT_QR_CODE)
                .build()
            val scanner = BarcodeScanning.getClient(scannerOptions)

            val imageAnalysis = ImageAnalysis.Builder()
                .build()
                .also {
                    it.setAnalyzer(cameraExecutor!!) { imageProxy ->
                        processImageProxy(scanner, imageProxy)
                    }
                }

            try {
                cameraProvider.unbindAll()
                cameraProvider.bindToLifecycle(this, CameraSelector.DEFAULT_BACK_CAMERA, preview, imageAnalysis)
            } catch (e: Exception) {
                Log.e("TicketScanFragment", "Camera binding failed", e)
            }
        }, ContextCompat.getMainExecutor(requireContext()))
    }

    @OptIn(ExperimentalGetImage::class)
    private fun processImageProxy(scanner: com.google.mlkit.vision.barcode.BarcodeScanner, imageProxy: ImageProxy) {
        val mediaImage = imageProxy. image
        if (mediaImage != null && !isProcessing) {
            val image = InputImage.fromMediaImage(mediaImage, imageProxy.imageInfo.rotationDegrees)

            scanner.process(image)
                .addOnSuccessListener { barcodes ->
                    for (barcode in barcodes) {
                        val qrValue = barcode.rawValue
                        if (qrValue != null) {
                            onQrCodeDetected(qrValue)
                            break
                        }
                    }
                }
                .addOnCompleteListener {
                    imageProxy.close()
                }
                .addOnFailureListener {
                    imageProxy.close()
                }
        }
        else {
            imageProxy.close()
        }

    }

    private fun onQrCodeDetected(qrCode: String) {
        if (isProcessing) return

        isProcessing = true
        val token = StorageUtils.getToken(requireContext()) ?: ""
        if (token.isNotEmpty()) {
            viewModel.validateTicket(token, qrCode)
        }
    }

    private fun observeViewModel() {
        viewModel.validationResult.observe(viewLifecycleOwner) { result ->
            if (result == null) return@observe

            validationStatusTextView.visibility = View.VISIBLE

            if (result.success != null) {
                validationStatusTextView.text = "Successful ticket validation!"
                validationStatusTextView.setBackgroundResource(R.drawable.bg_success)
                statusIcon.setImageResource(R.drawable.ic_success)
                statusIcon.visibility = View.VISIBLE
            } else {
                validationStatusTextView.text = "Error during validation: ${result.error ?: "Unknown error"}"
                validationStatusTextView.setBackgroundResource(R.drawable.bg_error)
                statusIcon.setImageResource(R.drawable.ic_error)
                statusIcon.visibility = View.VISIBLE
            }

            Handler(Looper.getMainLooper()).postDelayed({
                Log.d("TicketScanFragment", "Jegy feldolgozás befejezve")
                isProcessing = false
            }, 1000)

            validationStatusTextView.postDelayed({
                validationStatusTextView.visibility = View.GONE
                statusIcon.visibility = View.GONE
            }, 5000)
        }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        cameraExecutor?.shutdown()
    }

    @Deprecated("Deprecated in Java")
    override fun onRequestPermissionsResult(
        requestCode: Int, permissions: Array<String>, grantResults: IntArray
    ) {
        if (requestCode == CAMERA_PERMISSION_REQUEST_CODE) {
            if (allPermissionsGranted()) {
                startCamera()
            } else {
                validationStatusTextView.text = "Camera permission is required to scan tickets."
            }
        }
    }

    private fun showPinDialog() {
        val dialogView = layoutInflater.inflate(R.layout.dialog_pin_entry, null)
        val pinEditText = dialogView.findViewById<EditText>(R.id.pinEditText)

        val dialog = AlertDialog.Builder(requireContext())
            .setView(dialogView)
            .setCancelable(false)
            .setPositiveButton("OK", null)
            .setNegativeButton("Cancel") { dialogInterface, _ ->
                dialogInterface.dismiss()
            }
            .create()

        dialog.setOnShowListener {
            val okButton = dialog.getButton(AlertDialog.BUTTON_POSITIVE)
            okButton.setOnClickListener {
                val enteredPin = pinEditText.text.toString()
                if (enteredPin == "0000") {
                    dialog.dismiss()
                    onBackPressedCallback.isEnabled = false
                    requireActivity().onBackPressed()
                } else {
                    pinEditText.error = "Incorrect PIN"
                }
            }
        }

        dialog.show()
    }

}
