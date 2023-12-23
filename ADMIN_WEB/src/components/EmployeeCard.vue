<template>
  <v-card height="100%" class="d-flex flex-column" min-width="200">
      <v-sheet class="text-center" color="primary">
        <v-icon size="120" icon="mdi-account-outline"></v-icon>
      </v-sheet>
      <v-card-title class="text-center"> {{ employee.firstname }} {{ employee.lastname }} </v-card-title>
      <v-card-subtitle class="flex-1-1">
        <p>Role: {{ employee.role }}</p>
        <p v-if="employee.phone_number">Phone: {{ employee.phone_number }}</p>
        <p>Email: {{ employee.email }}</p>
        <p>Created on: {{ created }}</p>
      </v-card-subtitle>
      <v-card-actions class="justify-space-evenly">
        <v-btn prepend-icon="mdi-trash-can-outline" color="red" @click="deleteEmployee">
          Delete
        </v-btn>
        <v-btn prepend-icon="mdi-pencil-outline" @click="editEmployee">
          Edit
        </v-btn>
      </v-card-actions>
  </v-card>
</template>

<script setup>
import { computed } from 'vue';

const props = defineProps(['employee'])
const emit = defineEmits(['delete', 'edit'])

const created = computed(() => {
  if(!props.employee.created_at) return null
  let date = new Date(props.employee.created_at)
  return date.toLocaleDateString()
})

function deleteEmployee() {
  emit('delete')
}
function editEmployee() {
  emit('edit')
}
</script>

<style scoped>

</style>