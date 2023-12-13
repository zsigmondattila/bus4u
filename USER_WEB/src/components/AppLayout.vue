<template>
  <v-app>
    <v-app-bar>
      <v-app-bar-nav-icon @click.stop="isNavOpen = !isNavOpen"></v-app-bar-nav-icon>
      <v-app-bar-title>
        <RouterLink :to="{ name: 'home' }">
          <LogoWide :fill="$vuetify.theme.current.colors.primary" class="logo"/>
        </RouterLink>
      </v-app-bar-title>
      <template #append v-if="!user.accessToken">
        <v-btn title="Login" icon="mdi-login" @click="navigate('login')"></v-btn>
        <v-btn title="Register" icon="mdi-account-plus" @click="navigate('register')"></v-btn>
      </template>
      <template #append v-else>
        <span>{{ user.lastName }}</span>
        <v-btn title="Account" icon="mdi-account-circle-outline"></v-btn>
        <v-btn title="Logout" icon="mdi-logout" @click="logout"></v-btn>
      </template>
    </v-app-bar>

    <v-navigation-drawer color="primary" v-model="isNavOpen">
      <v-list nav class="h-100 d-flex flex-column">
        <v-list-item prepend-icon="mdi-home" title="Home" value="home" :to="{ name: 'home' }"></v-list-item>
        <v-list-item prepend-icon="mdi-bus" title="Schedule" value="schedule" :to="{ name: 'schedule' }"></v-list-item>
        <v-list-item prepend-icon="mdi-map-marker-outline" title="Stations" value="stations" :to="{ name: 'stations' }"></v-list-item>
        <v-list-item prepend-icon="mdi-crosshairs-gps" title="Live map" value="live" :to="{ name: 'live' }"></v-list-item>
        <v-spacer></v-spacer>
        <v-list-item prepend-icon="mdi-information-outline" title="About" value="about" :to="{ name: 'about' }"></v-list-item>
      </v-list>
    </v-navigation-drawer>

    <v-main>
      <div class="content">
        <v-snackbar v-model="isLoggedOut">
          Logout successfull
        </v-snackbar>
        <slot></slot>
      </div>
    </v-main>
  </v-app>
</template>

<script setup>
import { ref } from 'vue';
import router from '@/router';
import { RouterLink } from 'vue-router';
import { userStore } from '@/stores/userStore';
import LogoWide from './LogoWide.vue';

const user = userStore()
const isLoggedOut = ref(false)
const isNavOpen = ref(document.body.offsetWidth >= 1280)

function logout() {
  user.signOut().then(() => isLoggedOut.value = true)
}

function navigate(page) {
  router.push({ name: page });
}
</script>

<style scoped>
.content {
  padding: 15px;
  max-width: 1200px;
  margin: 0 auto;
}
.logo {
  height: 42px;
  vertical-align: middle;
}

@media screen and (min-width: 600px) {
  .content {
    padding: 25px;
  }
}
</style>