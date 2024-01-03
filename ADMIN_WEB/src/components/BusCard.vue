<template>
  <v-card height="100%" class="d-flex flex-column" min-width="200">
      <v-sheet class="text-center" color="primary">
        <v-icon size="120" icon="mdi-bus"></v-icon>
      </v-sheet>
      <v-card-title class="text-center"> {{ bus.brand }} </v-card-title>
      <v-card-subtitle class="flex-1-1">
        <p>License plate: {{ bus.license_plate }}</p>
        <p>Capacity: {{ bus.capacity }}</p>
        <p>Manufactured: {{ bus.manufacturing_year }}</p>
        <p>Road tax valid: {{ roadTax }}</p>
        <p>Insurance valid: {{ insurance }}</p>
        <p>Technical exam: {{ technicalExam }}</p>
      </v-card-subtitle>
      <v-card-actions class="justify-space-evenly">
        <v-btn prepend-icon="mdi-trash-can-outline" color="red" @click="deleteBus">
          Delete
        </v-btn>
        <v-btn prepend-icon="mdi-pencil-outline" @click="editBus">
          Edit
        </v-btn>
      </v-card-actions>
  </v-card>
</template>

<script setup>
import { computed } from 'vue';

const props = defineProps(['bus'])
const emit = defineEmits(['delete', 'edit'])

const roadTax = computed(() => {
  if(!props.bus.road_tax) return null
  let date = new Date(props.bus.road_tax)
  return date.toLocaleDateString()
})

const insurance = computed(() => {
  if(!props.bus.insurance) return null
  let date = new Date(props.bus.insurance)
  return date.toLocaleDateString()
})

const technicalExam = computed(() => {
  if(!props.bus.technical_exam) return null
  let date = new Date(props.bus.technical_exam)
  return date.toLocaleDateString()
})

function deleteBus() {
  emit('delete')
}

function editBus() {
  emit('edit')
}
</script>

<style scoped>

</style>