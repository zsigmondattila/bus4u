<template>
  <div v-if="trip.departure_times.length" class="border d-flex flex-wrap flex-sm-nowrap justify-center">
    <v-list-item class="flex-1-1"
      density="compact"
      :subtitle="`${trip.from_station} ➞ ${trip.to_station}`"
      prepend-icon="mdi-bus">
      <template #title>
        <b>{{ trip.departure_times[0] }}</b> • {{trip.route_name}}
      </template>
    </v-list-item>
    <div class="flex-0-0-100 flex-sm-0-0 pa-3">
      <v-text-field class="pa-0" variant="outlined" hide-details="auto" density="compact" type="number" min="1" max="50" v-model="count" :rules="ticketRules">
        <template #prepend>
          <div class="rounded border h-100 d-flex px-3 align-center">
            <span class="text-body-1"> <b>{{ trip.ticket_price }}</b> Lei </span>
          </div>
        </template>
        <template #append>
          <v-btn color="primary" type="secondary" height="44" variant="outlined" @click="buy"> Buy </v-btn>
        </template>
      </v-text-field>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue';
import router from '@/router';
import axios from 'axios';
import { userStore } from '@/stores/userStore';

const user = userStore();
const props = defineProps(['trip'])
const emit = defineEmits(['purchased'])

const count = ref(1)

const ticketRules = [
  (n) => n <= 50 || 'Too much',
  (n) => n > 0 || 'Not enough'
]

function buy() {
  if(!user.uid) router.push({name: 'login'});
  axios.post('https://bus4u.fast-table.com/v1/generate_a_ticket',
    { quantity: count.value, ticket_price: props.trip.ticket_price, type:'normal', route_uid: props.trip.route_uid, from_station_uid: props.trip.from_station_uid, to_station_uid: props.trip.to_station_uid, company_uid: props.trip.company_uid },
    { headers: { Authorization: user.authorization }})
    .then(rsp => {
      emit('purchased', rsp.data)
    }).catch(err => console.log(err))
}
</script>

<style scoped>
</style>