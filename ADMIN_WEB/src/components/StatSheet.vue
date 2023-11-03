<template>
  <v-sheet max-width="300" class="mx-auto" @mouseenter="isHovering = true" @mouseleave="isHovering = false">
    <v-responsive :aspect-ratio="16 / 9" class="align-center text-center">
      <div class="d-flex flex-column h-100">
        <h2 class="text-h2" :class="{ h2hover: isHovering }">{{ value }}</h2>
        <p class="text-body-1" :class="{ phover: isHovering }"> {{ label }} </p>
      </div>
    </v-responsive>
  </v-sheet>
</template>

<script setup>
import { ref } from 'vue';

defineProps(['label', 'value'])

const isHovering = ref(false);
</script>

<style scoped>
.h2hover {
  color: rgb(var(--v-theme-primary)) !important;
}
.phover {
  color: rgb(var(--v-theme-adjacent));
}
</style>