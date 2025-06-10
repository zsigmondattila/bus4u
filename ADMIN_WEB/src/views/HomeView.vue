<template>
  <AppLayout>
    <SectionTitle>
      Statistics
    </SectionTitle>
    <v-container>
      <v-row justify="center">
        <v-col cols="12" class="py-0" xl="3" align-self="center">
          <p class="text-subtitle-1 text-sm-h6 text-xl-h4">Last month</p>
        </v-col>
        <v-col cols="12" sm="6" md="4" xl="3">
          <StatSheet label="Users" :value="stats.month_users" />
        </v-col>
        <v-col cols="12" sm="6" md="4" xl="3">
          <StatSheet label="Tickets sold" :value="stats.month_tickets" />
        </v-col>
        <v-col cols="12" sm="6" md="4" xl="3">
          <StatSheet label="LEI income" :value="stats.month_income / 100" />
        </v-col>
      </v-row>
      <v-row justify="center">
        <v-col cols="12" class="py-0" xl="3" align-self="center">
          <p class="text-subtitle-1 text-sm-h6 text-xl-h4">Last year</p>
        </v-col>
        <v-col cols="12" sm="6" md="4" xl="3">
          <StatSheet label="Users" :value="stats.year_users" />
        </v-col>
        <v-col cols="12" sm="6" md="4" xl="3">
          <StatSheet label="Tickets sold" :value="stats.year_tickets" />
        </v-col>
        <v-col cols="12" sm="6" md="4" xl="3">
          <StatSheet label="LEI income" :value="stats.year_income / 100" />
        </v-col>
      </v-row>
      <v-row justify="center">
        <v-col cols="12" class="py-0" xl="3" align-self="center">
          <p class="text-subtitle-1 text-sm-h6 text-xl-h4">All time</p>
        </v-col>
        <v-col cols="12" sm="6" md="4" xl="3">
          <StatSheet label="Users" :value="stats.all_users" />
        </v-col>
        <v-col cols="12" sm="6" md="4" xl="3">
          <StatSheet label="Tickets sold" :value="stats.all_tickets" />
        </v-col>
        <v-col cols="12" sm="6" md="4" xl="3">
          <StatSheet label="LEI income" :value="stats.all_income / 100" />
        </v-col>
      </v-row>
    </v-container>
  </AppLayout>
</template>

<script setup>
import { ref } from 'vue';
import axios from 'axios';
import { userStore } from '@/stores/userStore';
import AppLayout from '@/components/AppLayout.vue';
import SectionTitle from '@/components/SectionTitle.vue';
import StatSheet from '@/components/StatSheet.vue';

const user = userStore()
const stats = ref({
  all_income: 0,
  all_tickets: 0,
  all_users: 0,
  month_income: 0,
  month_tickets: 0,
  month_users: 0,
  year_income: 0,
  year_tickets: 0,
  year_users: 0
})

axios.get('/v1/admin/statistics', { params: { company_uid: user.company_uid } })
  .then(rsp => {
    stats.value = rsp.data
  }).catch(() => {
    stats.value = {
      all_income: 0,
      all_tickets: 0,
      all_users: 0,
      month_income: 0,
      month_tickets: 0,
      month_users: 0,
      year_income: 0,
      year_tickets: 0,
      year_users: 0
    }
  })
</script>

<style scoped></style>