package com.bus4u.pos

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.widget.*
import androidx.core.app.ActivityCompat
import androidx.fragment.app.Fragment
import com.google.android.gms.location.*
import okhttp3.*
import okhttp3.MediaType.Companion.toMediaTypeOrNull
import org.json.JSONObject
import java.io.IOException

// Egyszerű adatmodell az útvonalakhoz
data class RouteInfo(val name: String, val routeUid: String)

class GPSFragment : Fragment() {

    private lateinit var busSpinner: Spinner
    private lateinit var routeSpinner: Spinner
    private lateinit var trackingSwitch: Switch
    private lateinit var locationTextView: TextView
    private lateinit var scanTicketButton: Button

    private val client = OkHttpClient()

    private var busList = mutableListOf<String>()
    private var routeList = mutableListOf<RouteInfo>()

    private var selectedBus: String? = null
    private var selectedRoute: String? = null
    private var isTracking = false

    // Helyadatok kezeléséhez
    private lateinit var fusedLocationClient: FusedLocationProviderClient
    private lateinit var locationCallback: LocationCallback
    private var currentLatitude: String = ""
    private var currentLongitude: String = ""

    // Handler a periodikus helyadat küldéshez (például 30 mp-ként)
    private val handler = Handler(Looper.getMainLooper())
    private val locationUpdateInterval: Long = 30000 // 30 másodperc

    override fun onCreateView(
        inflater: android.view.LayoutInflater, container: android.view.ViewGroup?,
        savedInstanceState: Bundle?
    ): android.view.View? {
        return inflater.inflate(R.layout.fragment_gps, container, false)
    }

    override fun onViewCreated(view: android.view.View, savedInstanceState: Bundle?) {
        busSpinner = view.findViewById(R.id.busSpinner)
        routeSpinner = view.findViewById(R.id.routeSpinner)
        trackingSwitch = view.findViewById(R.id.trackingSwitch)
        locationTextView = view.findViewById(R.id.locationTextView)
        scanTicketButton = view.findViewById(R.id.scanTicketButton)

        fusedLocationClient = LocationServices.getFusedLocationProviderClient(requireActivity())

        fetchBuses()
        fetchRoutes()

        // Busz kiválasztása
        busSpinner.onItemSelectedListener = object : AdapterView.OnItemSelectedListener {
            override fun onNothingSelected(parent: AdapterView<*>?) {}
            override fun onItemSelected(
                parent: AdapterView<*>?, view: android.view.View?,
                position: Int, id: Long
            ) {
                selectedBus = busList[position]
            }
        }

        // Útvonal kiválasztása
        routeSpinner.onItemSelectedListener = object : AdapterView.OnItemSelectedListener {
            override fun onNothingSelected(parent: AdapterView<*>?) {}
            override fun onItemSelected(
                parent: AdapterView<*>?, view: android.view.View?,
                position: Int, id: Long
            ) {
                selectedRoute = routeList[position].routeUid
            }
        }

        trackingSwitch.setOnCheckedChangeListener { _, isChecked ->
            isTracking = isChecked
            if (isTracking) {
                setBusTracked()
                enableLocationUpdates()
                startSendingLocationPeriodically()
            } else {
                setBusUntracked()
                stopLocationUpdates()
                handler.removeCallbacks(sendLocationRunnable)
            }
        }

        scanTicketButton.setOnClickListener {
            // Például áttérés a ScanTicketFragment-re
            activity?.supportFragmentManager?.beginTransaction()
                ?.replace(R.id.fragment_container, ScanTicketFragment())
                ?.addToBackStack(null)
                ?.commit()
        }
    }

    // --- Hálózati kérések ---

    private fun fetchBuses() {
        val prefs = requireContext().getSharedPreferences("myPrefs", Context.MODE_PRIVATE)
        val companyUid = prefs.getString("company", "") ?: ""
        val token = prefs.getString("token", "") ?: ""

        val url = "https://api.bus4u.online/v1/admin/get_buses_of_a_company?company_uid=$companyUid"
        val request = Request.Builder()
            .url(url)
            .get()
            .header("Authorization", "Bearer $token")
            .build()

        client.newCall(request).enqueue(object : Callback {
            override fun onFailure(call: Call, e: IOException) {
                // Hibakezelés
                e.printStackTrace()
            }

            override fun onResponse(call: Call, response: Response) {
                if (response.isSuccessful) {
                    val jsonStr = response.body?.string()
                    val buses = JSONObject("{\"buses\":$jsonStr}").getJSONArray("buses")
                    busList.clear()
                    for (i in 0 until buses.length()) {
                        val busObj = buses.getJSONObject(i)
                        busList.add(busObj.getString("license_plate"))
                    }
                    activity?.runOnUiThread {
                        busSpinner.adapter =
                            ArrayAdapter(requireContext(), android.R.layout.simple_spinner_item, busList)
                    }
                } else {
                    // Hibakezelés
                }
            }
        })
    }

    private fun fetchRoutes() {
        val prefs = requireContext().getSharedPreferences("myPrefs", Context.MODE_PRIVATE)
        val companyUid = prefs.getString("company", "") ?: ""
        val token = prefs.getString("token", "") ?: ""

        val url = "https://api.bus4u.online/v1/admin/get_routes_of_a_company?company_uid=$companyUid"
        val request = Request.Builder()
            .url(url)
            .get()
            .header("Authorization", "Bearer $token")
            .build()

        client.newCall(request).enqueue(object : Callback {
            override fun onFailure(call: Call, e: IOException) {
                e.printStackTrace()
            }

            override fun onResponse(call: Call, response: Response) {
                if (response.isSuccessful) {
                    val jsonStr = response.body?.string()
                    val jsonObj = JSONObject(jsonStr)
                    val routesArray = jsonObj.getJSONArray("routes")
                    routeList.clear()
                    for (i in 0 until routesArray.length()) {
                        val routeObj = routesArray.getJSONObject(i)
                        routeList.add(
                            RouteInfo(
                                name = routeObj.getString("name"),
                                routeUid = routeObj.getString("route_uid")
                            )
                        )
                    }
                    activity?.runOnUiThread {
                        val routeNames = routeList.map { it.name }
                        routeSpinner.adapter = ArrayAdapter(requireContext(), android.R.layout.simple_spinner_item, routeNames)
                    }
                } else {
                    // Hibakezelés
                }
            }
        })
    }

    private fun setBusTracked() {
        val prefs = requireContext().getSharedPreferences("myPrefs", Context.MODE_PRIVATE)
        val token = prefs.getString("token", "") ?: ""
        if (selectedBus != null) {
            val formBody = FormBody.Builder()
                .add("license_plate", selectedBus!!)
                .build()

            val request = Request.Builder()
                .url("https://api.bus4u.online/v1/admin/set_a_bus_tracked")
                .post(formBody)
                .header("Authorization", "Bearer $token")
                .build()

            client.newCall(request).enqueue(object : Callback {
                override fun onFailure(call: Call, e: IOException) { e.printStackTrace() }
                override fun onResponse(call: Call, response: Response) {
                    if (!response.isSuccessful) {
                        // Hibakezelés
                    }
                }
            })
        }
    }

    private fun setBusUntracked() {
        val prefs = requireContext().getSharedPreferences("myPrefs", Context.MODE_PRIVATE)
        val token = prefs.getString("token", "") ?: ""
        if (selectedBus != null) {
            val formBody = FormBody.Builder()
                .add("license_plate", selectedBus!!)
                .build()

            val request = Request.Builder()
                .url("https://api.bus4u.online/v1/admin/set_a_bus_untracked")
                .post(formBody)
                .header("Authorization", "Bearer $token")
                .build()

            client.newCall(request).enqueue(object : Callback {
                override fun onFailure(call: Call, e: IOException) { e.printStackTrace() }
                override fun onResponse(call: Call, response: Response) {
                    if (!response.isSuccessful) {
                        // Hibakezelés
                    }
                }
            })
        }
    }

    private fun sendCurrentLocation() {
        val prefs = requireContext().getSharedPreferences("myPrefs", Context.MODE_PRIVATE)
        val token = prefs.getString("token", "") ?: ""

        if (isTracking && selectedBus != null && selectedRoute != null) {
            val json = JSONObject().apply {
                put("license_plate", selectedBus)
                put("route_uid", selectedRoute)
                put("latitude", currentLatitude)
                put("longitude", currentLongitude)
            }

            val requestBody = RequestBody.create(
                "application/json; charset=utf-8".toMediaTypeOrNull(), json.toString()
            )

            val request = Request.Builder()
                .url("https://api.bus4u.online/v1/admin/change_bus_location")
                .post(requestBody)
                .header("Authorization", "Bearer $token")
                .build()

            client.newCall(request).enqueue(object : Callback {
                override fun onFailure(call: Call, e: IOException) { e.printStackTrace() }
                override fun onResponse(call: Call, response: Response) {
                    if (!response.isSuccessful) {
                        // Hibakezelés
                    }
                }
            })
        }
    }

    // --- Helyadatok kezelése ---
    private fun enableLocationUpdates() {
        if (ActivityCompat.checkSelfPermission(
                requireContext(),
                Manifest.permission.ACCESS_FINE_LOCATION
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            ActivityCompat.requestPermissions(requireActivity(), arrayOf(Manifest.permission.ACCESS_FINE_LOCATION), 1001)
            return
        }

        val locationRequest = LocationRequest.create().apply {
            interval = 5000
            fastestInterval = 2000
            priority = LocationRequest.PRIORITY_HIGH_ACCURACY
        }

        locationCallback = object : LocationCallback() {
            override fun onLocationResult(result: LocationResult) {
                val location = result.lastLocation
                if (location != null) {
                    currentLatitude = location.latitude.toString()
                }
                if (location != null) {
                    currentLongitude = location.longitude.toString()
                }
                activity?.runOnUiThread {
                    locationTextView.text = "Latitude: $currentLatitude, Longitude: $currentLongitude"
                }
            }
        }

        fusedLocationClient.requestLocationUpdates(locationRequest, locationCallback, Looper.getMainLooper())
    }

    private fun stopLocationUpdates() {
        if (::locationCallback.isInitialized) {
            fusedLocationClient.removeLocationUpdates(locationCallback)
        }
    }

    // Runnable a periodikus helyküldéshez
    private val sendLocationRunnable = object : Runnable {
        override fun run() {
            sendCurrentLocation()
            handler.postDelayed(this, locationUpdateInterval)
        }
    }

    private fun startSendingLocationPeriodically() {
        handler.post(sendLocationRunnable)
    }

    override fun onDestroyView() {
        super.onDestroyView()
        handler.removeCallbacks(sendLocationRunnable)
        stopLocationUpdates()
    }
}
