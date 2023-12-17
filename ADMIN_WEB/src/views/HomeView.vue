<template>
  <AppLayout>
    <SectionTitle>
      Statistics
    </SectionTitle>
    <v-container>
      <v-row v-for="stat in stats" :key="stat.name" justify="center">
        <v-col cols="12" class="py-0" xl="3" align-self="center">
          <p class="text-subtitle-1 text-sm-h6 text-xl-h4">{{ stat.name }}</p>
        </v-col>
        <v-col cols="12" sm="6" md="4" xl="3">
          <StatSheet label="Tickets sold" :value="stat.values[0]" />
        </v-col>
        <v-col cols="12" sm="6" md="4" xl="3">
          <StatSheet label="Different users" :value="stat.values[1]" />
        </v-col>
        <v-col cols="12" sm="6" md="4" xl="3">
          <StatSheet label="LEI income" :value="stat.values[2]" />
        </v-col>
      </v-row>
    </v-container>
  </AppLayout>
</template>

<script setup>
import AppLayout from '@/components/AppLayout.vue';
import SectionTitle from '@/components/SectionTitle.vue';
import StatSheet from '@/components/StatSheet.vue';

const stats = [
  {
    name: 'Last month',
    values: [50, 265, 150]
  },
  {
    name: 'Last year',
    values: [120, 855, 300]
  },
  {
    name: 'All time',
    values: [480, 1056, 805]
  }
]
</script>

<style scoped>

</style>