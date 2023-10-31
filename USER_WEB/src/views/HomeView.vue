<template>
  <AppLayout>
    <SectionTitle>
      Plan your travel
      <template #description>
        Fill the form to get available buses
      </template>
    </SectionTitle>
    <v-form @submit.prevent="onSubmit" class="my-10">
      <v-container class="px-0">
        <v-row justify="center">
          <v-col cols="12" sm="6">
            <v-select :items="stations" label="From" v-model="form.from" class="text-field" hide-details="auto" :rules="stationRule"></v-select>
          </v-col>
          <v-col cols="12" sm="6">
            <v-select :items="stations" label="To" v-model="form.to" class="text-field" hide-details="auto" :rules="stationRule"></v-select>
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
const stations = ref(['Sapientia', 'Aleea Carpatii', 'Izvorul Rece', 'Combinat']);
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
  from: '',
  to: '',
  date: date.toLocaleDateString().replaceAll('. ', '-').slice(0, 10),
  time: date.toLocaleTimeString().slice(0, 5),
})

const stationRule = [
  (v) => !!v || 'Please select a station.'
]

function onSubmit() {
  console.log(form);
}

// axios.get('/stations').then((rsp) => rsp.json()).then((json) => stations = json.stations)
</script>

<style scoped>

</style>