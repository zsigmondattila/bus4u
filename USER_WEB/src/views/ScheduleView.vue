<template>
  <AppLayout>
    <SectionTitle>
      Schedule
      <template #description>
        Departure timetable
      </template>
    </SectionTitle>
    <v-form @submit.prevent="onSubmit" validate-on="submit" class="my-5">
      <v-container class="px-0">
        <v-row justify="center">
          <v-col cols="12" sm="4">
            <v-autocomplete :items="cities" :item-props="getName" label="City" :loading="!cities.length" v-model="form.city" class="text-field" hide-details="auto" :rules="rules" @update:model-value="getStations"></v-autocomplete>
          </v-col>
          <v-col cols="12" sm="4">
            <v-autocomplete :items="stations" :item-props="getName" label="Station" :disabled="!form.city" :loading="!stations.length && !!form.city" v-model="form.station" class="text-field" hide-details="auto" :rules="rules" @update:model-value="getBuses"></v-autocomplete>
          </v-col>
          <v-col cols="12" sm="4">
            <v-select :items="buses" :item-props="getName" label="Bus" :disabled="!form.station" :loading="!buses.length && !!form.station" v-model="form.bus" class="text-field" hide-details="auto" :rules="rules"></v-select>
          </v-col>
          <v-col cols="12" sm="2" style="text-align: center;">
            <v-btn type="submit" color="primary"> Search </v-btn>
          </v-col>
        </v-row>
      </v-container>
    </v-form>

    <v-table class="border rounded">
      <tbody v-if="timetable">
        <tr v-for="day in timetable" :key="day.name">
          <td>{{ day.name }}</td>
          <td v-for="time in day.departure_times" :key="time">{{ time }}</td>
        </tr>
      </tbody>
      <h3 v-else class="fallback"> Here will appear the timetable </h3>
    </v-table>
    <Map v-if="route" :stations="route" :isRoute="true"/>
  </AppLayout>
</template>

<script setup>
import axios from "axios";
import { onMounted, reactive, ref } from "vue";
import AppLayout from "@/components/AppLayout.vue"
import SectionTitle from "@/components/SectionTitle.vue"
import Map from "../components/Map.vue";

const cities = ref([]);
const stations = ref([]);
const buses = ref([]);

const timetable = ref([])
const route = ref([])

const form = reactive({
  city: '',
  station: '',
  bus: ''
})

const rules = [
  (v) => !!v || 'This field cannot be empty'
]

function getName(item){
  return { title: item.name };
}

async function getCities() {
  cities.value = (await axios.get('https://bus4u.fast-table.com/v1/get_cities')).data.cities
}

async function getStations(city) {
  stations.value = (await axios.get('https://bus4u.fast-table.com/v1/get_stations_by_city', { params:{ city_uid: city.city_uid }})).data.stations
}

async function getBuses(station) {
  buses.value = (await axios.get('https://bus4u.fast-table.com/v1/get_routes_by_station', { params:{ station_uid: station.station_uid }})).data.routes
}

async function onSubmit(e) {
  if(!(await e).valid) return
  timetable.value = (await axios.get('https://bus4u.fast-table.com/v1/get_departure_times_for_station_in_route', { params:{ station_uid: form.station.station_uid, route_uid: form.bus.route_uid }})).data
  route.value = (await axios.get('https://bus4u.fast-table.com/v1/get_stations_of_a_route', { params: {route_uid: form.bus.route_uid }})).data.stations
}

onMounted(() => {
  getCities();
})
</script>

<style scoped>
.fallback {
  opacity: .5;
  text-align: center;
  margin: 10px;
}
</style>