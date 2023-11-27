<template>
  <div ref="mapRef" class="map rounded mt-10"></div>
</template>

<script setup>
import { onBeforeUpdate, onMounted, onUnmounted, ref } from 'vue';
import mapboxgl from 'mapbox-gl';
import axios from 'axios';

const props = defineProps(['stations', 'isRoute', 'panTo'])
const mapRef = ref(null);

let map = null;
let markers = [];
let customPoint = null;
let currentLocation = [];
let waypoints = [];

function resetRoute() {
  const data = {
    'type': 'Feature',
    'properties': {},
    'geometry': {
      'type': 'LineString',
      'coordinates': waypoints
    }
  }
  if(map.getSource('route')) map.getSource('route').setData(data)
}

function addStations(array) {
  array.forEach(station => {
    const popup = new mapboxgl.Popup({className: 'my-popup'}).setLngLat([station.longitude, station.latitude])
      .setHTML(`<h3>${station.name}</h3><p>${station.address}<p>`).setMaxWidth("300px").addTo(map);
    markers.push(new mapboxgl.Marker({ color: "#EF6C00" }).setLngLat([station.longitude, station.latitude]).setPopup(popup).addTo(map));
  })
  if(props.panTo && props.panTo.length) {
    map.setZoom(11).panTo(props.panTo)
  }
}

async function addRoute() {
  waypoints = []
  if(props.stations.length > 25) {
    props.stations.forEach(station => {
      waypoints.push([station.longitude, station.latitude]);
    })
  } else {
    let str = 'https://api.mapbox.com/directions/v5/mapbox/driving/'
    props.stations.forEach(station => {
      if(station != props.stations[0]) str += ';'
      str += `${station.longitude},${station.latitude}`
    })
    let way = await axios.get(str, { params: { geometries: 'geojson', 'access_token': import.meta.env.VITE_MAPBOX_TOKEN }})
    if(way.data) waypoints = way.data.routes[0].geometry.coordinates
  }

  const data = {
    'type': 'Feature',
    'properties': {},
    'geometry': {
      'type': 'LineString',
      'coordinates': waypoints
    }
  }
  if(map.getSource('route')){ 
    map.getSource('route').setData(data)
    if(!props.panTo || !props.panTo.length) map.setZoom(11).panTo(waypoints[0])
  }
}

if(navigator.geolocation) {
  navigator.geolocation.getCurrentPosition((p) => {
    currentLocation = [p.coords.longitude, p.coords.latitude]
    customPoint = new mapboxgl.Marker({ color: "#2979FF" }).setLngLat(currentLocation).addTo(map);
    map.panTo(currentLocation)
  });
}

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
    if(props.stations) addStations(props.stations)
    if(props.isRoute){
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
    }
  });
})

onBeforeUpdate(() => {
  markers.forEach(marker => marker.remove())
  markers = []
  if(!props.stations.length) resetRoute();
  else {
    addStations(props.stations)
    if(props.isRoute) addRoute()
  }
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
</style>