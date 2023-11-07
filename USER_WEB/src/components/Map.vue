<template>
  <div ref="mapRef" class="map rounded my-15">

  </div>
</template>

<script setup>
import { onBeforeUpdate, onMounted, onUnmounted, ref } from 'vue';
import mapboxgl from 'mapbox-gl';

const props = defineProps(['coordinateArray'])
const mapRef = ref(null);
const map = ref(null);

onMounted(() => {
  mapboxgl.accessToken = import.meta.env.VITE_MAPBOX_TOKEN;
  map.value = new mapboxgl.Map({
    container: mapRef.value,
    style: 'mapbox://styles/mapbox/streets-v11',
    center: [24.57143496138591, 46.53342927867064],
    zoom: 12,
  });
  map.value.on('load', () => {
    map.value.addSource('route', {
      'type': 'geojson',
      'data': {
        'type': 'Feature',
        'properties': {},
        'geometry': {
          'type': 'LineString',
          'coordinates': props.coordinateArray
        }
      }
    });
    map.value.addLayer({
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
  });
})

onBeforeUpdate(() => {
  const data = {
    'type': 'Feature',
    'properties': {},
    'geometry': {
      'type': 'LineString',
      'coordinates': props.coordinateArray
    }
  }
  map.value.getSource('route').setData(data)
  map.panTo(props.coordinateArray[0])
})

onUnmounted(() => {
  map.value.remove();
  map.value = null;
})
</script>

<style scoped>
.map {
  height: 500px;
}
</style>