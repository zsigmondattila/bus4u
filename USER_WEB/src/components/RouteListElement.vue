<template>
  <div class="border d-flex flex-wrap justify-center">
    <v-list-item class="flex-1-1"
      density="compact"
      :subtitle="`${trip.start_station} ➞ ${trip.destination_station}`"
      prepend-icon="mdi-bus">
      <template #title>
        <b>{{ trip.departure_times[0].departure_times[0] }}</b> • {{trip.route_name}}
      </template>
      <template #append>
          <span class="text-body-1"> <b>{{ trip.ticket_price }}</b> Lei </span>
        </template>
    </v-list-item>
    <div class="flex-0-0-100 flex-sm-0-0 pa-3">
      <v-text-field class="pa-0" variant="outlined" hide-details="auto" density="compact" type="number" min="1" max="50" v-model="count" :rules="ticketRules">
        <template #append>
          <v-btn color="primary" type="secondary" height="44" variant="outlined" @click="buy"> Buy </v-btn>
        </template>
      </v-text-field>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue';
import { userStore } from '@/stores/userStore';

const user = userStore();
const props = defineProps(['trip'])

const count = ref(1)

const ticketRules = [
  (n) => n <= 50 || 'Too much',
  (n) => n > 0 || 'Not enough'
]

function buy() {
  if(!user.uid) console.error('No user logged in');
  console.log(`${count.value} ticket(s) sold for bus: ${props.trip.name} = ${props.trip.price * count.value} Lei`);
}
</script>

<style scoped>

</style>