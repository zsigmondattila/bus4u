<template>
  <v-app>
    <v-app-bar>
      <v-app-bar-nav-icon></v-app-bar-nav-icon>
      <v-app-bar-title>
        <RouterLink to="/">Bus4U</RouterLink>
      </v-app-bar-title>
      <template #append>
        <v-btn icon="mdi-login"></v-btn>
        <v-btn icon="mdi-account-plus"></v-btn>
      </template>
    </v-app-bar>
    <v-navigation-drawer
      image="https://cdn.vuetifyjs.com/images/backgrounds/bg-2.jpg"
      permanent
      theme="dark">
      <v-list nav>
        <v-list-item prepend-icon="mdi-home" title="Kezdőlap" value="home" to="/"></v-list-item>
        <v-list-item prepend-icon="mdi-bus" title="Menetrend" value="schedule" to="/schedule"></v-list-item>
        <v-list-item prepend-icon="mdi-information-outline" title="Rólunk" value="about"></v-list-item>
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
import { RouterLink } from 'vue-router';
</script>

<style scoped>
.content {
  padding: 15px;
}
</style>