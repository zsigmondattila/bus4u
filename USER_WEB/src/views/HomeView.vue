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
            <v-autocomplete :items="cities" label="Start city" :item-props="getName" :loading="!cities.length" v-model="form.fromCity" class="text-field" hide-details="auto" :rules="stationRule" @update:modelValue="getStartStation"></v-autocomplete>
          </v-col>
          <v-col cols="12" sm="6">
            <v-autocomplete :items="startStations" label="Start station" :item-props="getName" :disabled="!form.fromCity" :loading="!startStations.length && !!form.fromCity" v-model="form.fromStation" class="text-field" hide-details="auto" :rules="stationRule"></v-autocomplete>
          </v-col>
          <v-col cols="12" sm="6">
            <v-autocomplete :items="cities" label="Destination city" :item-props="getName" :loading="!cities.length" v-model="form.toCity" class="text-field" hide-details="auto" :rules="stationRule" @update:modelValue="getDestStation"></v-autocomplete>
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
        <RouteListElement v-for="route in routes" :key="route.id" :trip="route"></RouteListElement>
    </v-list>
  </AppLayout>
</template>

<script setup>
import { ref, reactive } from 'vue';
import axios from 'axios';
import AppLayout from '@/components/AppLayout.vue';
import SectionTitle from '@/components/SectionTitle.vue';
import RouteListElement from '@/components/RouteListElement.vue';

const date = new Date();
const startStations = ref([]);
const destStations = ref([]);
const cities = ref([])
const routes = ref([
  {
    id: 1,
    name: '44',
    time: '10:40',
    from: 'Sapientia',
    to: 'Combinat',
    price: 2
  },
  {
    id: 2,
    name: '26',
    time: '10:55',
    from: 'Sapientia',
    to: 'Aleea Carpatii',
    price: 3
  },
  {
    id: 3,
    name: '27',
    time: '11:15',
    from: 'Sapientia',
    to: 'Poli 2',
    price: 2
  }
]);

const form = reactive({
  fromCity: '',
  toCity: '',
  fromStation: '',
  toStation: '',
  date: date.toLocaleDateString().replaceAll('. ', '-').slice(0, 10),
  time: date.toLocaleTimeString().slice(0, 5),
})

const stationRule = [
  (v) => !!v || 'Please select an option.'
]
const uniqueStation = [
  (v) => !!v || 'Please select an option.',
  (v) => v.station_uid != form.fromStation.station_uid || 'The 2 stations must not be the same.'
]

function onSubmit() {
  console.log(form);
}

function getName(item){
  return { title: item.name };
}

async function getStartStation(city){
  axios.get('https://bus4u.fast-table.com/v1/get_stations_by_city', { params: { city_uid: city.city_uid }})
    .then(rsp => {
      if(rsp.status == 200) startStations.value = rsp.data.stations
    }).catch(e => console.error(e))
}

async function getDestStation(city){
  axios.get('https://bus4u.fast-table.com/v1/get_stations_by_city', { params: { city_uid: city.city_uid }})
    .then(rsp => {
      if(rsp.status == 200) destStations.value = rsp.data.stations
    }).catch(e => console.error(e))
}

axios.get('https://bus4u.fast-table.com/v1/get_cities')
  .then((rsp) => {
    cities.value = rsp.data.cities
  }).catch(err => console.error(err))
</script>

<style scoped>

</style>