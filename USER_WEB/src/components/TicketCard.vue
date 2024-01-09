<template>
  <v-card height="100%" class="mx-auto d-flex flex-column" min-width="150" max-width="300" color="orange-lighten-5">
      <v-responsive aspect-ratio="1">
        <v-sheet class="text-center h-100">
          <v-img v-if="ticket.qr" :src="ticket.qr"></v-img>
          <div v-else class="h-100 d-flex justify-center">
            <v-icon size="150" icon="mdi-ticket-confirmation-outline" class="align-self-center text-medium-emphasis"></v-icon>
          </div>
        </v-sheet>
      </v-responsive>
      <v-card-title class="text-center text-primary"> {{ ticket.ticket_uid }} </v-card-title>
      <v-card-text class="flex-1-1">
        <p>Route: {{ ticket.route_name }}</p>
        <p>From: {{ ticket.from_station_name }}</p>
        <p>To: {{ ticket.to_station_name }}</p>
        <p>Price: {{ ticket.ticket_price/100 }} Lei</p>
        <p>Purchased: {{ created }}</p>
        <p>Expiration: 
          <span v-if="ticket.is_valid">{{ expiration }}</span>
          <b v-else> already used </b>
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