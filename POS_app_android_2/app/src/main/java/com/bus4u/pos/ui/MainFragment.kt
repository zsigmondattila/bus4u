package com.bus4u.pos.ui

import android.Manifest
import android.annotation.SuppressLint
import android.content.pm.PackageManager
import android.location.Location
import android.os.Bundle
import android.util.Log
import android.view.View
import android.widget.*
import androidx.activity.result.contract.ActivityResultContracts
import androidx.core.content.ContextCompat
import androidx.fragment.app.Fragment
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.lifecycleScope
import androidx.navigation.fragment.findNavController
import com.bus4u.pos.R
import com.bus4u.pos.domain.viewmodel.MainViewModel
import com.bus4u.pos.domain.viewmodel.MainViewModelFactory
import com.bus4u.pos.util.ApiClient
import com.bus4u.pos.util.StorageUtils
import com.google.android.gms.location.FusedLocationProviderClient
import com.google.android.gms.location.LocationServices
import com.google.android.gms.maps.CameraUpdateFactory
import com.google.android.gms.maps.GoogleMap
import com.google.android.gms.maps.MapView
import com.google.android.gms.maps.OnMapReadyCallback
import com.google.android.gms.maps.model.LatLng
import com.google.android.gms.maps.model.Marker
import com.google.android.gms.maps.model.MarkerOptions
import com.google.android.material.switchmaterial.SwitchMaterial
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch
import kotlin.coroutines.resume
import kotlin.coroutines.suspendCoroutine

class MainFragment : Fragment(R.layout.fragment_main), OnMapReadyCallback {

    private lateinit var viewModel: MainViewModel

    private lateinit var busAutoComplete: AutoCompleteTextView
    private lateinit var routeAutoComplete: AutoCompleteTextView
    private lateinit var fusedLocationClient: FusedLocationProviderClient

    private var locationUpdateJob: Job? = null

    private lateinit var mapView: MapView
    private var googleMap: GoogleMap? = null
    private var busMarker: Marker? = null

    private val locationPermissionLauncher = registerForActivityResult(
        ActivityResultContracts.RequestPermission()
    ) {}

    override fun onResume() {
        super.onResume()
        mapView.onResume()
    }

    override fun onPause() {
        super.onPause()
        mapView.onPause()
    }

    override fun onDestroy() {
        super.onDestroy()
        mapView.onDestroy()
    }

    @SuppressLint("UseSwitchCompatOrMaterialCode", "ClickableViewAccessibility")
    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        busAutoComplete = view.findViewById(R.id.busAutoComplete)
        routeAutoComplete = view.findViewById(R.id.routeAutoComplete)
        val trackSwitch = view.findViewById<SwitchMaterial>(R.id.trackSwitch)
        val ticketScanButton = view.findViewById<Button>(R.id.ticketScannerButton)
        val logoImageView = view.findViewById<ImageView>(R.id.logoImageView)

        fusedLocationClient = LocationServices.getFusedLocationProviderClient(requireContext())

        val apiService = ApiClient.apiService
        val factory = MainViewModelFactory(apiService)
        viewModel = ViewModelProvider(this, factory)[MainViewModel::class.java]

        val token = StorageUtils.getToken(requireContext()) ?: ""
        val companyUid = StorageUtils.getCompanyUid(requireContext()) ?: ""

        viewModel.fetchCompanyData(
            token,
            companyUid,
            onSuccess = { buses, routes ->
                val busNames = buses.map { it.license_plate }
                val routeNames = routes.map { it.name }

                requireActivity().runOnUiThread {
                    val busAdapter = ArrayAdapter(
                        requireContext(),
                        R.layout.dropdown_menu_popup_item,
                        busNames
                    )
                    busAutoComplete.setAdapter(busAdapter)

                    val routeAdapter = ArrayAdapter(
                        requireContext(),
                        R.layout.dropdown_menu_popup_item,
                        routeNames
                    )
                    routeAutoComplete.setAdapter(routeAdapter)
                }
            },
            onError = { message ->
                requireActivity().runOnUiThread {
                    Toast.makeText(requireContext(), message, Toast.LENGTH_SHORT).show()
                }
            }
        )

        mapView = view.findViewById(R.id.mapView)
        mapView.onCreate(savedInstanceState)
        mapView.getMapAsync(this)

        trackSwitch.setOnCheckedChangeListener { _, isChecked ->
            val selectedBusLicensePlate = busAutoComplete.text?.toString()
            val selectedRouteName = routeAutoComplete.text?.toString()

            if (selectedBusLicensePlate.isNullOrEmpty()) {
                Toast.makeText(requireContext(), "No bus selected!", Toast.LENGTH_SHORT).show()
                trackSwitch.isChecked = !isChecked
                return@setOnCheckedChangeListener
            }

            if (selectedRouteName.isNullOrEmpty()) {
                Toast.makeText(requireContext(), "No route selected!", Toast.LENGTH_SHORT).show()
                trackSwitch.isChecked = !isChecked
                return@setOnCheckedChangeListener
            }

            val selectedRoute = viewModel.getRouteByName(selectedRouteName)
            if (selectedRoute == null) {
                trackSwitch.isChecked = !isChecked
                return@setOnCheckedChangeListener
            }

            if (isChecked) {
                if (ContextCompat.checkSelfPermission(requireContext(), Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
                    locationPermissionLauncher.launch(Manifest.permission.ACCESS_FINE_LOCATION)
                    trackSwitch.isChecked = false
                    return@setOnCheckedChangeListener
                }

                viewModel.setBusTracked(token, selectedBusLicensePlate) { success, errorMessage ->
                    requireActivity().runOnUiThread {
                        if (success) {
                            mapView.visibility = View.VISIBLE
                            logoImageView.visibility = View.INVISIBLE
                            startLocationUpdates(token, selectedBusLicensePlate, selectedRoute.route_uid)
                        } else {
                            trackSwitch.isChecked = false
                        }
                    }
                }

            } else {
                viewModel.setBusUntracked(token, selectedBusLicensePlate) { success, errorMessage ->
                    requireActivity().runOnUiThread {
                        if (success) {
                            mapView.visibility = View.GONE
                            logoImageView.visibility = View.VISIBLE
                            stopLocationUpdates()
                        } else {
                            trackSwitch.isChecked = true
                        }
                    }
                }
            }
        }

        ticketScanButton.setOnClickListener {
            findNavController().navigate(R.id.action_mainFragment_to_ticketScanFragment)
        }
    }

    override fun onMapReady(map: GoogleMap) {
        googleMap = map
        // Alapértelmezett nézet (pl. Budapest)
        val defaultLocation = LatLng(47.4979, 19.0402)
        googleMap?.moveCamera(CameraUpdateFactory.newLatLngZoom(defaultLocation, 12f))
    }

    private fun updateBusLocationOnMap(latitude: Double, longitude: Double) {
        val position = LatLng(latitude, longitude)
        if (busMarker == null) {
            busMarker = googleMap?.addMarker(MarkerOptions().position(position).title("Busz helyzete"))
            googleMap?.moveCamera(CameraUpdateFactory.newLatLngZoom(position, 15f))
        } else {
            busMarker?.position = position
            googleMap?.animateCamera(CameraUpdateFactory.newLatLng(position))
        }
    }

    private fun startLocationUpdates(token: String, licensePlate: String, routeUid: String) {
        locationUpdateJob?.cancel()
        locationUpdateJob = lifecycleScope.launch {
            while (isActive) {
                val location = getLastKnownLocation()
                if (location != null) {
                    viewModel.sendBusLocation(token, licensePlate, routeUid, location.latitude, location.longitude)
                    updateBusLocationOnMap(location.latitude, location.longitude)
                } else {
                    Log.e("MainFragment", "No GPS location available")
                }
                delay(30_000)
            }
        }
    }

    private fun stopLocationUpdates() {
        locationUpdateJob?.cancel()
        locationUpdateJob = null
    }

    private suspend fun getLastKnownLocation(): Location? = suspendCoroutine { cont ->
        fusedLocationClient.lastLocation
            .addOnSuccessListener { location -> cont.resume(location) }
            .addOnFailureListener { cont.resume(null) }
    }
}