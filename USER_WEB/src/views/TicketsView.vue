<template>
  <AppLayout>
    <SectionTitle>
      My tickets
    </SectionTitle>
    <v-container>
      <v-row v-if="user.uid">
        <v-col v-for="ticket in tickets" :key="ticket.ticket_uid" cols="12" sm="6" md="4" lg="3">
          <TicketCard :ticket="ticket"/>
        </v-col>
        <div v-if="!tickets.length && !isLoading" class="border rounded w-100 pa-3 ma-5 text-center">
          <p class="text-subtitle-1 text-medium-emphasis"> There are no tickets yet, but you can purchase on the
            <RouterLink :to="{name: 'home'}" class="text-decoration-underline">home</RouterLink> page.
          </p>
        </div>
      </v-row>
      <v-row v-else>
        <v-col cols="12" sm="6" md="4" lg="3">
          <v-card :to="{name: 'login'}" height="100%" class="d-flex flex-column text-center" min-width="200">
            <v-sheet class="text-center" color="primary">
              <v-icon size="120" icon="mdi-login"></v-icon>
            </v-sheet>
            <v-spacer></v-spacer>
            <v-card-title> Login </v-card-title>
            <v-card-text> Please log in to see your tickets.</v-card-text>
            <v-spacer></v-spacer>
          </v-card>
        </v-col>
        <v-col cols="12" sm="6" md="4" lg="3">
          <v-card :to="{name: 'register'}" height="100%" class="d-flex flex-column text-center" min-width="200">
            <v-sheet class="text-center" color="primary">
              <v-icon size="120" icon="mdi-account-plus-outline"></v-icon>
            </v-sheet>
            <v-spacer></v-spacer>
            <v-card-title> Register </v-card-title>
            <v-card-text> Please register if you don't have account.</v-card-text>
            <v-spacer></v-spacer>
          </v-card>
        </v-col>
      </v-row>
      <v-row v-if="isLoading">
        <v-col v-for="index in 3" cols="6" sm="6" md="4" lg="3">
          <v-skeleton-loader type="card, paragraph" :loading="true"></v-skeleton-loader>
        </v-col>
      </v-row>
    </v-container>
  </AppLayout>
</template>

<script setup>
import { ref, watchEffect } from 'vue';
import axios from 'axios';
import QRCode from 'qrcode';
import { userStore } from '@/stores/userStore';
import AppLayout from '@/components/AppLayout.vue';
import SectionTitle from '@/components/SectionTitle.vue';
import TicketCard from '@/components/TicketCard.vue';

const user = userStore()
const isLoading = ref(false)
const tickets = ref([])

watchEffect(() => {
  if(user.uid) {
    isLoading.value = true
    axios.get('https://api.bus4u.online/v1/tickets_of_user', { headers: { Authorization: user.authorization}, params: { uid: user.uid }})
      .then(rsp => {
        isLoading.value = false
        tickets.value = rsp.data.sort((a, b) => {
          if(!a.is_valid && b.is_valid) return 1
          if(!b.is_valid && a.is_valid) return -1
          return b.date_of_purchase.localeCompare(a.date_of_purchase)
        })
        for(let i=0; i<tickets.value.length; i++) {
          if(!tickets.value[i].is_valid) continue
          QRCode.toDataURL(tickets.value[i].ticket_uid, { width: 250 }).then(rsp => tickets.value[i].qr = rsp)
        }
      }).catch(() => {
        tickets.value = []
        isLoading.value = false
      })
  }
})

</script>

<style scoped>

</style>