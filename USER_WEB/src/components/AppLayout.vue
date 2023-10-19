<template>
  <v-app>
    <v-app-bar>
      <v-app-bar-nav-icon @click.stop="isNavOpen = !isNavOpen"></v-app-bar-nav-icon>
      <v-app-bar-title>
        <RouterLink :to="{ name: 'home' }"> Bus4U </RouterLink>
      </v-app-bar-title>
      <template #append>
        <v-btn icon="mdi-login" :to="{ name: 'login' }"></v-btn>
        <v-btn icon="mdi-account-plus" :to="{ name: 'register' }"></v-btn>
      </template>
    </v-app-bar>

    <v-navigation-drawer color="primary" v-model="isNavOpen">
      <v-list nav class="h-100 d-flex flex-column">
        <v-list-item prepend-icon="mdi-home" title="Home" value="home" :to="{ name: 'home' }"></v-list-item>
        <v-list-item prepend-icon="mdi-bus" title="Schedule" value="schedule" :to="{ name: 'schedule' }"></v-list-item>
        <v-list-item prepend-icon="mdi-information-outline" title="About" value="about" :to="{ name: 'about' }"></v-list-item>
        <v-spacer></v-spacer>
        <v-list-item prepend-icon="mdi-cog-outline" title="Settings" value="settings" :to="{ name: 'settings' }"></v-list-item>
      </v-list>
    </v-navigation-drawer>

    <v-main>
      <div class="content">
        <slot></slot>
      </div>
    </v-main>
  </v-app>
</template>

<script setup>
import { ref } from 'vue';
import { RouterLink } from 'vue-router';

const isNavOpen = ref(false)
</script>

<style scoped>
.content {
  padding: 15px;
}
</style>