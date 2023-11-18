<template>
  <AppLayout>
    <SectionTitle>
      Stations
      <template #description>
        Edit stations
      </template>
    </SectionTitle>
    <v-list :items="stations" :item-props="getProps" border class="py-0 my-5" max-height="320">
      <template #append="{ item }">
        <v-btn icon="mdi-delete-outline" elevation="0" @click="deleteStation(item)"></v-btn>
      </template>
    </v-list>
    <div v-if="!formIsOpen" class="d-flex">
      <v-btn icon="mdi-plus-circle" class="mx-auto" @click="formIsOpen = true"></v-btn>
    </div>
    <v-form v-else @submit.prevent="addStation" validate-on="submit" class="my-5 bg-grey-darken-4 pa-5 border-md">
      <p class="text-subtitle-1"> Create new Station </p>
      <v-row justify="center" class="mt-1">
        <v-col cols="10">
          <v-text-field label="Station name" v-model="newStation.name" color="primary" :rules="nameRule" hide-details="auto"></v-text-field>
        </v-col>
        <v-col cols="2">
          <v-btn type="reset" color="primary" variant="outlined" class="h-100" block @click="cancelAddStation"> Cancel </v-btn>
        </v-col>
        <v-col cols="5">
          <v-text-field label="Longitude" type="number" v-model="newStation.coordinates[0]" color="primary" :rules="coordinateRule" hide-details="auto"></v-text-field>
        </v-col>
        <v-col cols="5">
          <v-text-field label="Latitude" type="number" v-model="newStation.coordinates[1]" color="primary" :rules="coordinateRule" hide-details="auto"></v-text-field>
        </v-col>
        <v-col cols="2">
          <v-btn type="submit" color="primary" class="h-100" block> Save </v-btn>
        </v-col>
      </v-row>
      <p class="text-caption text-disabled pa-1 opacity-5"> Click on the map to fill the coordinates. </p>
    </v-form>
    <MapBox :stations="stations" v-model:pointer="newStation.coordinates"/>
  </AppLayout>
</template>

<script setup>
import axios from 'axios';
import { reactive, ref } from 'vue';
import AppLayout from '../components/AppLayout.vue';
import SectionTitle from '../components/SectionTitle.vue';
import MapBox from '../components/MapBox.vue';

const stations = ref([])
const formIsOpen = ref(false)
const newStation = reactive({
  coordinates: [],
  name: '',
  city: '',
  address: ''
})

const nameRule = [
  (v) => !!v || 'The field is required',
  (v) => /^[A-Z].+$/.test(v) || 'The field must be a valid name'
]

const coordinateRule = [
  (v) => !!v || 'Type here the coordinate or click on the map',
  (v) => /^[0-9]+\.?[0-9]*$/.test(v) || 'The field must be a valid coordinate'
]

function getProps(station) {
  return { title: station.name, subtitle: `${station.longitude} - ${station.latitude}`, border: '', 'prepend-icon': 'mdi-map-marker-outline' }
}

function deleteStation(station){
  console.log(station.name + ' deleted');
  updateStations();
}

function cancelAddStation() {
  newStation.name = ''
  newStation.coordinates = []
  formIsOpen.value = false
}

async function addStation(e){
  let rsp = await e;
  if(!rsp.valid) return;

  let info = await axios.get(`https://api.mapbox.com/geocoding/v5/mapbox.places/${newStation.coordinates[0]},${newStation.coordinates[1]}.json`, { params: { 'access_token': import.meta.env.VITE_MAPBOX_TOKEN }})
  let arr = info.data.features;
  newStation.city = arr[2].text
  newStation.address = `${arr[0].text} ${arr[0].address}`
  console.log(newStation);

  let createRsp = await axios.post('https://bus4u.fast-table.com/v1/admin/create_station', { name: newStation.name, latitude: newStation.coordinates[1], longitude: newStation.coordinates[0], city: newStation.city, address: newStation.address })
  if (createRsp.status == 200) {
    console.log('Station created successfully');
    formIsOpen.value = false;
    newStation.name = ''
    newStation.coordinates = []
    newStation.city = ''
    newStation.address = ''
    updateStations();
  }
}

function updateStations() {
  axios.get('https://bus4u.fast-table.com/v1/get_stations')
  .then(rsp => {
    if (rsp.status == 200) {
      stations.value = rsp.data.stations
      console.log(stations.value);
    }
  })
}

axios.get('https://bus4u.fast-table.com/v1/get_stations')
  .then(rsp => {
    if (rsp.status == 200) {
      stations.value = rsp.data.stations
      console.log(stations.value);
    }
  })
</script>

<style scoped>
</style>