<template>
  <AppLayout>
    <SectionTitle>
      Stations
      <template #description>
        Browse stations on the map and apply filter by city or route
      </template>
    </SectionTitle>
    <v-form @submit.prevent="onSubmit" validate-on="submit" class="my-5">
      <v-container class="px-0">
        <v-row justify="center">
          <v-col cols="12" sm="5">
            <v-autocomplete :items="cities" :item-props="getName" label="City" :disabled="!!form.bus" :loading="!cities.length" v-model="form.city" class="text-field" hide-details="auto" @update:modelValue="getBuses" clearable></v-autocomplete>
          </v-col>
          <v-col cols="12" sm="5">
            <v-autocomplete :items="buses" :item-props="getName" label="Route" :disabled="!!form.city" :loading="!buses.length && !!form.city" v-model="form.bus" class="text-field" hide-details="auto" clearable></v-autocomplete>
          </v-col>
          <v-col cols="12" sm="2" style="text-align: center;">
            <v-btn type="submit" color="primary"> Filter </v-btn>
          </v-col>
        </v-row>
      </v-container>
    </v-form>

    <Map ref="mapBox" :stations="stations"/>
  </AppLayout>
</template>

<script setup>
import { onMounted, reactive, ref } from 'vue';
import axios from 'axios';
import AppLayout from '../components/AppLayout.vue';
import SectionTitle from '../components/SectionTitle.vue';
import Map from '../components/Map.vue';

const form = reactive({
  city: null,
  bus: null,
})

const mapBox = ref(null)
const cities = ref([])
const buses = ref([])
const stations = ref([])

function getName(item){
  return { title: item.name };
}

function onSubmit() {
  if(form.city && !form.bus) {
    axios.get('https://api.bus4u.online/v1/get_stations_by_city', {params: { city_uid: form.city.city_uid }})
    .then(rsp => {
      if(rsp.status == 200) {
        stations.value = rsp.data.stations
        if(stations.value.length) mapBox.value.panTo([stations.value[0].longitude, stations.value[0].latitude])
      }
    }).catch(() => stations.value = [])
  } else if(form.bus) {
    axios.get('https://api.bus4u.online/v1/get_stations_of_a_route', {params: { route_uid: form.bus.route_uid }})
    .then(rsp => {
      if(rsp.status == 200) {
        stations.value = rsp.data.stations
        if(stations.value.length) mapBox.value.panTo([stations.value[0].longitude, stations.value[0].latitude])
      }
    }).catch(() => stations.value = [])
  } else {
    axios.get('https://api.bus4u.online/v1/get_stations')
      .then(rsp => {
          if(rsp.status == 200) stations.value = rsp.data.stations
        }).catch(() => stations.value = [])
  }
}

async function getBuses() {
  axios.get('https://api.bus4u.online/v1/get_routes')
    .then(rsp => {
      if(rsp.status == 200) buses.value = rsp.data.routes
    }).catch(() => buses.value = [])
}

onMounted(() => {
  axios.get('https://api.bus4u.online/v1/get_stations')
  .then(rsp => {
      if(rsp.status == 200) stations.value = rsp.data.stations
    }).catch(() => stations.value = [])

  axios.get('https://api.bus4u.online/v1/get_cities')
    .then(rsp => {
      if(rsp.status == 200) cities.value = rsp.data.cities
    }).catch(() => cities.value = [])
  axios.get('https://api.bus4u.online/v1/get_routes')
    .then(rsp => {
      if(rsp.status == 200) buses.value = rsp.data.routes
    }).catch(() => buses.value = [])
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