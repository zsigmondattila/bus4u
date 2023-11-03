<template>
  <AppLayout>
    <SectionTitle>
      Statistics
    </SectionTitle>
    <v-container>
      <v-row v-for="stat in stats" :key="stat.name" justify="center">
        <v-col cols="12">
          <h3 class="text-h6">{{ stat.name }}</h3>
        </v-col>
        <v-col cols="12" sm="4">
          <StatSheet label="Tickets sold" :value="stat.values[0]" />
        </v-col>
        <v-col cols="12" sm="4">
          <StatSheet label="KMs traveled" :value="stat.values[1]" />
        </v-col>
        <v-col cols="12" sm="4">
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