<template>
  <v-card height="100%" class="d-flex flex-column" min-width="200">
      <v-sheet class="text-center" color="primary">
        <v-icon size="120" icon="mdi-account-outline"></v-icon>
      </v-sheet>
      <v-card-title class="text-center"> {{ employee.firstname }} {{ employee.lastname }} </v-card-title>
      <v-card-text class="flex-1-1">
        <p>Role: {{ employee.role }}</p>
        <p>Email: {{ employee.email }}</p>
      </v-card-text>
      <v-card-actions class="justify-center">
        <v-btn prepend-icon="mdi-trash-can-outline" color="red" @click="deleteEmployee">
          Delete
        </v-btn>
      </v-card-actions>
  </v-card>
</template>

<script setup>
defineProps(['employee'])
const emit = defineEmits(['delete'])

function deleteEmployee() {
  emit('delete')
}
</script>

<style scoped>

</style>