<template>
  <div ref="mapRef" class="map rounded mt-10">

  </div>
</template>

<script setup>
import { onBeforeUpdate, onMounted, onUnmounted, ref } from 'vue';
import mapboxgl from 'mapbox-gl';

const props = defineProps(['stations', 'route'])
const mapRef = ref(null);
let map = null;
let markers = [];
let points = [];

function addStations(array) {
  if(!array.length) return;
  array.forEach(station => {
    markers.push(new mapboxgl.Marker({ color: "#EF6C00" }).setLngLat(station.coordinates).addTo(map));
    points.push(station.coordinates);
  })
  map.panTo(array[0].coordinates)
}

function addRoute() {
  if(!points.length) return;

  const data = {
    'type': 'Feature',
    'properties': {},
    'geometry': {
      'type': 'LineString',
      'coordinates': points
    }
  }
  map.getSource('route').setData(data)
  map.panTo(points[0])

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
          'coordinates': points
        }
      }
    });
    if(props.stations) addStations(props.stations)
    if(props.route){
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
          'line-width': 8
        }
      });
    }
  });
})

onBeforeUpdate(() => {
  markers.forEach(marker => marker.remove())
  markers = []
  points = []
  addStations(props.stations)
  if(props.route) {
    addRoute()
  }
})

onUnmounted(() => {
  map.remove();
  map = null;
})
</script>

<style scoped>
.map {
  height: 500px;
}
</style>