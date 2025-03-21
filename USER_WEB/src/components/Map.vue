<template>
  <div class="container mt-8">
    <div ref="mapRef" class="map rounded"></div>
    <div v-if="controls" class="pa-2">
      <v-row dense>
        <v-col cols="12" sm="4">
          <v-checkbox label="Current location" v-model="showLocation" color="#297bFF" hide-details="auto"></v-checkbox>
        </v-col>
        <v-col cols="12" sm="4">
          <v-checkbox label="Live bus location" v-model="showBuses" color="#bc1251" hide-details="auto"></v-checkbox>
        </v-col>
        <v-col cols="12" sm="4">
          <v-checkbox label="Stations" v-model="showStations" color="#EF6C00" hide-details="auto"></v-checkbox>
        </v-col>
      </v-row>
    </div>
  </div>
</template>

<script setup>
import { onBeforeUpdate, onMounted, onUnmounted, ref } from 'vue';
import mapboxgl from 'mapbox-gl';
import axios from 'axios';
import { watch } from 'vue';

const props = defineProps(['stations', 'buses', 'enableRoute', 'hideStations', 'controls'])
const mapRef = ref(null);
const showStations = ref(!props.hideStations);
const showLocation = ref(true);
const showBuses = ref(true);

let map = null;
let stationMarkers = [];
let busMarkers = [];
let currentLocation = null;
let waypoints = [];

function panTo(coord, zoom) {
  if (!map) return
  if (zoom !== undefined) map.setZoom(zoom).panTo(coord)
  else map.panTo(coord);
}

function resetRoute() {
  const data = {
    'type': 'Feature',
    'properties': {},
    'geometry': {
      'type': 'LineString',
      'coordinates': waypoints
    }
  }
  if (map.getSource('route')) map.getSource('route').setData(data)
}

function addStations(array) {
  if (!showStations.value) return
  array.forEach(station => {
    const popup = new mapboxgl.Popup({ className: 'my-popup' }).setLngLat([station.longitude, station.latitude]).setMaxWidth("300px")
      .setHTML(`<h3>${station.name}</h3><a href="https://google.com/maps/search/?api=1&query=${station.latitude},${station.longitude}" target="_blank">${station.address}<a>`);
    stationMarkers.push(new mapboxgl.Marker({ color: "#EF6C00" }).setLngLat([station.longitude, station.latitude]).setPopup(popup).addTo(map));
  })
}

function addBuses(array) {
  if (!showBuses.value) return
  array.forEach(bus => {
    const popup = new mapboxgl.Popup({ className: 'my-popup' }).setLngLat([bus.longitude, bus.latitude])
      .setHTML(`<h3>${bus.license_plate}</h3><p>${bus.brand}</p><p>Capacity: ${bus.capacity}</p>`).setMaxWidth("300px");
    busMarkers.push(new mapboxgl.Marker({ color: "#bc1251" }).setLngLat([bus.longitude, bus.latitude]).setPopup(popup).addTo(map));
  })
}

async function addRoute() {
  waypoints = []
  if (props.stations.length < 2) return
  if (props.stations.length > 100) {
    props.stations.forEach(station => {
      waypoints.push([station.longitude, station.latitude]);
    })
  } else {
    let base = 'https://api.mapbox.com/directions/v5/mapbox/driving/'
    let str = ''
    for (let i = 0; i < props.stations.length; i++) {
      str += `${props.stations[i].longitude},${props.stations[i].latitude}`
      if (i > 0 && i % 20 === 0) {
        if (i + 1 < props.stations.length) str += `;${props.stations[i + 1].longitude},${props.stations[i + 1].latitude}`
        let way = await axios.get(`${base}${str}`, { params: { geometries: 'geojson', 'access_token': import.meta.env.VITE_MAPBOX_TOKEN } })
        if (way.data) waypoints = waypoints.concat(way.data.routes[0].geometry.coordinates)
        str = ''
      } else str += ';'
    }
    if (str.length > 0) {
      let way = await axios.get(`${base}${str.slice(0, -1)}`, { params: { geometries: 'geojson', 'access_token': import.meta.env.VITE_MAPBOX_TOKEN } })
      if (way.data) waypoints = waypoints.concat(way.data.routes[0].geometry.coordinates)
    }
  }

  const data = {
    'type': 'Feature',
    'properties': {},
    'geometry': {
      'type': 'LineString',
      'coordinates': waypoints
    }
  }
  if (map.getSource('route')) {
    map.getSource('route').setData(data)
  }
}

watch(showLocation, () => {
  if (showLocation.value) {
    if (navigator.geolocation && !props.hideLocation) {
      navigator.geolocation.getCurrentPosition((p) => {
        let current = [p.coords.longitude, p.coords.latitude]
        currentLocation = new mapboxgl.Marker({ color: "#297bFF" }).setLngLat(current).addTo(map);
        map.panTo(current)
      });
    }
  } else {
    currentLocation.remove();
    currentLocation = null;
  }
})

watch(showStations, () => {
  if (showStations.value && props.stations) {
    addStations(props.stations)
    if (props.enableRoute) addRoute()
  } else {
    stationMarkers.forEach(marker => marker.remove())
    stationMarkers = []
    resetRoute();
  }
})

watch(showBuses, () => {
  if (showBuses.value && props.buses) {
    addBuses(props.buses)
  } else {
    busMarkers.forEach(marker => marker.remove())
    busMarkers = []
  }
})

if (navigator.geolocation) {
  navigator.geolocation.getCurrentPosition((p) => {
    let current = [p.coords.longitude, p.coords.latitude]
    currentLocation = new mapboxgl.Marker({ color: "#297bFF" }).setLngLat(current).addTo(map);
    map.panTo(current)
  });
}

defineExpose({ panTo })

onMounted(() => {
  mapboxgl.accessToken = import.meta.env.VITE_MAPBOX_TOKEN;
  map = new mapboxgl.Map({
    container: mapRef.value,
    style: 'mapbox://styles/mapbox/streets-v11',
    center: [24.57143496138591, 46.53342927867064],
    zoom: 12,
  });
  map.on('load', () => {
    map.addSource('route', {
      'type': 'geojson',
      'data': {
        'type': 'Feature',
        'properties': {},
        'geometry': {
          'type': 'LineString',
          'coordinates': waypoints
        }
      }
    });
    map.addControl(new mapboxgl.NavigationControl());
    if (props.stations) addStations(props.stations)
    if (props.buses) addBuses(props.buses)
    if (props.enableRoute) {
      map.addLayer({
        'id': 'route',
        'type': 'line',
        'source': 'route',
        'layout': {
          'line-join': 'round',
          'line-cap': 'round'
        },
        'paint': {
          'line-color': '#EF6C00',
          'line-width': 5
        }
      });
      if (props.stations.length) addRoute()
    }
  });
})

onBeforeUpdate(() => {
  stationMarkers.forEach(marker => marker.remove())
  stationMarkers = []
  busMarkers.forEach(marker => marker.remove())
  busMarkers = []
  if (!props.stations.length) resetRoute();
  else {
    addStations(props.stations)
    if (props.enableRoute) addRoute()
  }
  if (props.buses) addBuses(props.buses)
})

onUnmounted(() => {
  map.remove();
  map = null;
})
</script>

<style scoped>
.map {
  height: 480px;
}

.container {
  height: 100%;
}
</style>