<template>
  <div v-if="trip.departure_time" class="border d-flex flex-wrap flex-sm-nowrap justify-center">
    <v-list-item class="flex-1-1" density="compact" :subtitle="`${trip.from_station} ➞ ${trip.to_station}`"
      prepend-icon="mdi-bus">
      <template #title>
        <b>{{ departureTime }}</b> • {{ trip.route_name }}
      </template>
    </v-list-item>
    <div class="flex-0-0-100 flex-sm-0-0 pa-3">
      <v-text-field class="pa-0" variant="outlined" hide-details="auto" density="compact" type="number" min="1" max="50"
        v-model="count" :rules="ticketRules">
        <template #prepend>
          <div class="rounded border h-100 d-flex px-3 align-center">
            <span class="text-body-1"> <b>{{ trip.ticket_price }}</b> Lei </span>
          </div>
        </template>
        <template #append>
          <v-btn color="primary" type="secondary" height="44" variant="outlined" @click="buy" :loading="isLoading"> Buy
          </v-btn>
        </template>
      </v-text-field>
    </div>
  </div>
</template>

<script setup>
import { computed, ref } from 'vue';
import router from '@/router';
import { userStore } from '@/stores/userStore';
import axios from 'axios';

const user = userStore();
const props = defineProps(['trip'])

const count = ref(1)
const isLoading = ref(false)

const ticketRules = [
  (n) => n <= 50 || 'Too much',
  (n) => n > 0 || 'Not enough'
]
const departureTime = computed(() => {
  const d = new Date(props.trip.departure_time * 1000)
  const minutes = d.getUTCMinutes()
  return `${d.getUTCHours()}:${minutes > 9 ? minutes : '0' + minutes}`
})

async function buy() {
  if (!user.uid) {
    router.push({ name: 'login' });
    return;
  }
  isLoading.value = true

  const response = await axios.post("/create-checkout",
    { quantity: count.value, ticket_price: props.trip.ticket_price, type: 'normal', route_uid: props.trip.route_uid, from_station_uid: props.trip.from_station_uid, to_station_uid: props.trip.to_station_uid, company_uid: props.trip.company_uid },
    { headers: { Authorization: user.authorization } });
  if (response.status !== 200) {
    isLoading.value = false;
    console.error('Failed to create checkout session:', response);
    return;
  }
  const { clientSecret } = response.data;
  router.push({
    name: 'checkout',
    query: { client: clientSecret }
  });
}
</script>

<style scoped></style>