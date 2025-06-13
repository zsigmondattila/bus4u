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
          <v-btn color="primary" type="secondary" height="44" variant="outlined" @click="emit('clicked', trip, count)"
            :loading="trip.isLoading"> Buy
          </v-btn>
        </template>
      </v-text-field>
    </div>
  </div>
</template>

<script setup>
import { computed, ref } from 'vue';

const props = defineProps(['trip'])
const emit = defineEmits(['clicked'])

const count = ref(1)

const ticketRules = [
  (n) => n <= 50 || 'Too much',
  (n) => n > 0 || 'Not enough'
]
const departureTime = computed(() => {
  const d = new Date(props.trip.departure_time * 1000)
  const minutes = d.getUTCMinutes()
  return `${d.getUTCHours()}:${minutes > 9 ? minutes : '0' + minutes}`
})
</script>

<style scoped></style>