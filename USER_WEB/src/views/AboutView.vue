<template>
  <AppLayout>
    <SectionTitle>
      About us
      <template #description>
        <p>We want to simplify the process of public transportation.</p>
      </template>
    </SectionTitle>
    <div>
      <br>
      <p class="text-caption text-md-subtitle-1">Created by Bus4U team:</p>
      <ul class="ml-10 text-caption text-md-body-2">
        <li>Bodó Bálint</li>
        <li>Portik Szabolcs</li>
        <li>Zsigmond Attila</li>
      </ul>
      <br>
      <p class="text-caption">Sapientia EMTE 2023</p>
    </div>
  </AppLayout>
</template>

<script setup>
import AppLayout from '../components/AppLayout.vue';
import SectionTitle from '../components/SectionTitle.vue';
</script>

<style scoped>

</style>