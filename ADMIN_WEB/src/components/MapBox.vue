<template>
  <div ref="mapRef" class="map rounded mt-10">

  </div>
</template>

<script setup>
import { onBeforeUpdate, onMounted, onUnmounted, ref } from 'vue';
import mapboxgl from 'mapbox-gl';

const props = defineProps(['stations', 'route', 'pointer'])
const emit = defineEmits(['update:pointer'])
const mapRef = ref(null);
let map = null;
let markers = [];
let points = [];
let customPoint = null;

function addCustomPointer(coordinates){
  if(!coordinates.length) return
  customPoint = new mapboxgl.Marker({ color: "#bc1251" }).setLngLat(coordinates).addTo(map);
  map.panTo(coordinates)
}

function addStations(array) {
  if(!array.length) return;
  let c = [];
  array.forEach(station => {
    c = [station.longitude, station.latitude];
    markers.push(new mapboxgl.Marker({ color: "#EF6C00" }).setLngLat(c).addTo(map));
    points.push(c);
  })
  map.panTo(c)
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
  map.panTo(points[0]).zoomTo(11)

}

onMounted(() => {
  mapboxgl.accessToken = import.meta.env.VITE_MAPBOX_TOKEN;
  map = new mapboxgl.Map({
    container: mapRef.value,
    style: 'mapbox://styles/mapbox/streets-v11',
    center: [24.57143496138591, 46.53342927867064],
    zoom: 11,
  });
  map.on('load', () => {
    map.on('click', (e) => {
      emit('update:pointer', [e.lngLat.lng, e.lngLat.lat])
    })
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
  if(customPoint) customPoint.remove();
  if(props.pointer) addCustomPointer(props.pointer)
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