<template>
  <AppLayout>
    <SectionTitle>
      About
      <template #description>
        <p>The project and the team</p>
      </template>
    </SectionTitle>
    <div class="text-body-2 text-sm-body-1">
      <br>
      <p>One of the most environmentally friendly ways to travel is to choose public transport. The more people choose this form of travel, the cleaner environment we can live in, and the less congested the roads would be. Unfortunately, the choice of public transport also comes with many disadvantages.</p>
      <ul class="ml-8">
        <li>From the point of view of passengers, it is relatively difficult to choose the right bus for us, because it is not easy to find the timetables of the different companies anywhere. Even if we find this, there is still the possibility that the buses will be late, or worse, leave earlier.</li>
        <li>From the point of view of companies, it is often not easy to monitor the condition of the buses, the costs, and to keep track of the profit.</li>
      </ul>
      <p>By creating this application, we offer solutions to all these problems.</p>
      <br>
      <p class="">Bus4U team:</p>
      <ul class="ml-8 text-body-2">
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