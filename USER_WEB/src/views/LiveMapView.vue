<template>
  <AppLayout>
    <SectionTitle>
      Live map
      <template #description>
        Track live position of the buses on the map
      </template>
    </SectionTitle>
    <v-form @submit.prevent="onSubmit" validate-on="submit" class="my-5">
      <v-container class="px-0">
        <v-row justify="center">
          <v-col cols="12" sm="5">
            <v-autocomplete :items="cities" :item-props="getName" label="City" :loading="!cities.length" v-model="form.city" :rules="required" class="text-field" hide-details="auto" @update:modelValue="getRoutes"></v-autocomplete>
          </v-col>
          <v-col cols="12" sm="5">
            <v-autocomplete :items="routes" :item-props="getName" label="Route" :disabled="!form.city" :loading="!routes.length && !!form.city" v-model="form.route" :rules="required" class="text-field" hide-details="auto"></v-autocomplete>
          </v-col>
          <v-col cols="12" sm="2" style="text-align: center;">
            <v-btn type="submit" color="primary"> Show </v-btn>
          </v-col>
        </v-row>
      </v-container>
    </v-form>
    <Map ref="mapBox" :stations="stations" :toggleRoute="true" :hide-stations="true" controls="true" :buses="buses" :pan-to="center"/>
  </AppLayout>
</template>

<script setup>
import { onBeforeUnmount, onMounted, reactive, ref } from 'vue';
import axios from 'axios';
import AppLayout from '../components/AppLayout.vue';
import SectionTitle from '../components/SectionTitle.vue';
import Map from '../components/Map.vue';

const form = reactive({
  city: null,
  route: null,
})

const center = ref(false)
const cities = ref([])
const routes = ref([])
const stations = ref([])
const buses = ref([])
let updateInterval = null

function getName(item){
  return { title: item.name };
}

const required = [
  (v) => !!v || 'This field is required'
]

async function onSubmit(e) {
  let validation = await e
  if(!validation.valid) return
  clearInterval(updateInterval)
    axios.get('https://bus4u.fast-table.com/v1/get_stations_of_a_route', {params: { route_uid: form.route.route_uid }}) /// or on a route?
    .then(rsp => {
      if(rsp.status == 200) {
        stations.value = rsp.data.stations
        if(stations.value.length) center.value = [stations.value[0].longitude, stations.value[0].latitude]
        getBuses(form.route)
        updateInterval = setInterval(() => getBuses(form.route), 30000);
      }
    }).catch((e) => {
      stations.value = []
    })
}

function getBuses(route) {
  axios.get('https://bus4u.fast-table.com/v1/get_bus_locations_by_route', {params: { route_uid: route.route_uid }})
    .then(rsp => {
      if(rsp.status == 200) {
        buses.value = rsp.data
        if(buses.value.length) center.value = [buses.value[0].longitude, buses.value[0].latitude]
      }
    }).catch(() => {
      buses.value = []
    })
}

async function getRoutes(city) {
  axios.get('https://bus4u.fast-table.com/v1/get_routes_by_city', { params: { city_uid: city.city_uid }})
    .then(rsp => {
      if(rsp.status == 200) routes.value = rsp.data
    }).catch(() => routes.value = [])
}

onMounted(() => {
  axios.get('https://bus4u.fast-table.com/v1/get_cities')
    .then(rsp => {
      if(rsp.status == 200) cities.value = rsp.data.cities
    }).catch(() => cities.value = [])
})
onBeforeUnmount(() => {
  clearInterval(updateInterval)
})
</script>

<style scoped>
@media (min-width: 600px){
  .v-btn{
    height: 100%;
    width: 100%;
    font-size: medium;
  }
}
</style>