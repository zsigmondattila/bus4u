<template>
  <AppLayout>
    <SectionTitle>
      Plan your travel
      <template #description>
        Fill the form to get available buses
      </template>
    </SectionTitle>
    <v-form @submit.prevent="onSubmit" class="my-10" validate-on="submit">
      <v-container class="px-0">
        <v-row justify="center">
          <v-col cols="12" sm="6">
            <v-autocomplete :items="cities" label="Start city" :item-props="getName" :loading="!cities.length" v-model="form.fromCity" class="text-field" hide-details="auto" :rules="cityRule" @update:modelValue="getStartStation"></v-autocomplete>
          </v-col>
          <v-col cols="12" sm="6">
            <v-autocomplete :items="startStations" label="Start station" :item-props="getName" :disabled="!form.fromCity" :loading="!startStations.length && !!form.fromCity" v-model="form.fromStation" class="text-field" hide-details="auto"></v-autocomplete>
          </v-col>
          <v-col cols="12" sm="6">
            <v-autocomplete :items="cities" label="Destination city" :item-props="getName" :loading="!cities.length" v-model="form.toCity" class="text-field" hide-details="auto" :rules="cityRule" @update:modelValue="getDestStation"></v-autocomplete>
          </v-col>
          <v-col cols="12" sm="6">
            <v-autocomplete :items="destStations" label="Destination station" :item-props="getName" :disabled="!form.toCity" :loading="!destStations.length && !!form.toCity" v-model="form.toStation" class="text-field" hide-details="auto" :rules="uniqueStation"></v-autocomplete>
          </v-col>
          <v-col cols="12" sm="6">
            <v-text-field label="Date" type="date" v-model="form.date" class="text-field" hide-details="auto"></v-text-field>
          </v-col>
          <v-col cols="12" sm="6">
            <v-text-field label="Time" type="time" v-model="form.time" class="text-field" hide-details="auto"></v-text-field>
          </v-col>
          <v-col cols="12" style="text-align: center;">
            <v-btn type="submit" color="primary"> Search </v-btn>
          </v-col>
        </v-row>
      </v-container>
    </v-form>
    <v-list lines="two" border rounded class="py-0 my-10">
      <div v-if="!routes">
        <v-skeleton-loader v-for="index in 3" type="avatar, list-item-two-line, button@2" :boilerplate="!isLoadingRoutes"></v-skeleton-loader>
      </div>
      <p v-else-if="!routes.length" class="fallback"> No available trips found with the data given. </p>
      <RouteListElement v-else v-for="route in routes" :key="route.route_name" :trip="route"></RouteListElement>
    </v-list>
  </AppLayout>
</template>

<script setup>
import { ref, reactive } from 'vue';
import axios from 'axios';
import AppLayout from '@/components/AppLayout.vue';
import SectionTitle from '@/components/SectionTitle.vue';
import RouteListElement from '@/components/RouteListElement.vue';

const isLoadingRoutes = ref(false)

const date = new Date();
const startStations = ref([]);
const destStations = ref([]);
const cities = ref([])
const routes = ref(null);

const form = reactive({
  fromCity: '',
  toCity: '',
  fromStation: '',
  toStation: '',
  date: date.toLocaleDateString().replaceAll('. ', '-').slice(0, 10),
  time: date.toLocaleTimeString().slice(0, 5),
})

const cityRule = [
  (v) => !!v || 'Please select an option.'
]
const uniqueStation = [
  (v) => !v || v.station_uid != form.fromStation.station_uid || 'The 2 stations must not be the same.'
]

async function onSubmit(e) {
  if(!(await e).valid) return
  isLoadingRoutes.value = true
  axios.get('https://bus4u.fast-table.com/v1/get_available_tickets',
    { params: { start_city_uid: form.fromCity.city_uid, destination_city_uid: form.toCity.city_uid, start_station_uid: form.fromStation.station_uid || '', destination_station_uid: form.toStation.station_uid || '', date: form.date, time: form.time}}
    ).then(rsp => {
      console.log(rsp.data);
      if(rsp.status == 200) {
        routes.value = rsp.data.routes
        isLoadingRoutes.value = false
      }
    }).catch(e => console.error(e))
}

function getName(item){
  return { title: item.name };
}

async function getStartStation(city){
  if(!city) return
  axios.get('https://bus4u.fast-table.com/v1/get_stations_by_city', { params: { city_uid: city.city_uid }})
    .then(rsp => {
      if(rsp.status == 200) startStations.value = rsp.data.stations
    }).catch(() => startStations.value = [])
}

async function getDestStation(city){
  if(!city) return
  axios.get('https://bus4u.fast-table.com/v1/get_stations_by_city', { params: { city_uid: city.city_uid }})
    .then(rsp => {
      if(rsp.status == 200) destStations.value = rsp.data.stations
    }).catch(() => destStations.value = [])
}

axios.get('https://bus4u.fast-table.com/v1/get_cities')
  .then((rsp) => {
    cities.value = rsp.data.cities
  }).catch(() => cities.value = [])
</script>

<style scoped>
.fallback {
  opacity: .5;
  text-align: center;
  margin: 15px;
}

</style>