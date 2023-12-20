<template>
  <v-card height="100%" class="d-flex flex-column" min-width="150" max-width="300">
      <v-sheet class="text-center" color="primary">
        <v-img v-if="ticket.qr" :src="ticket.qr"></v-img>
        <v-icon v-else size="150" icon="mdi-ticket-outline"></v-icon>
      </v-sheet>
      <v-card-title class="text-center text-primary"> {{ ticket.ticket_uid }} </v-card-title>
      <v-card-text class="flex-1-1">
        <p>Route: {{ ticket.route_name }}</p>
        <p>From: {{ ticket.from_station_name }}</p>
        <p>To: {{ ticket.to_station_name }}</p>
        <p>Price: {{ ticket.ticket_price/100 }}</p>
        <p>Purchased: {{ created }}</p>
        <p>Exiration: 
          <span v-if="ticket.is_valid">{{ expiration }}</span>
          <span v-else > already used </span>
        </p>
      </v-card-text>
  </v-card>
</template>

<script setup>
import { computed } from 'vue';

const props = defineProps(['ticket'])

const created = computed(() => {
  if(!props.ticket.date_of_purchase) return null
  let date = new Date(props.ticket.date_of_purchase)
  return date.toLocaleDateString()
})
const expiration = computed(() => {
  if(!props.ticket.expiration_date) return null
  let date = new Date(props.ticket.expiration_date)
  return date.toLocaleDateString()
})
</script>

<style scoped>

</style>