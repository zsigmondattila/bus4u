import { defineStore } from 'pinia'
import { ref } from 'vue'

export const userStore = defineStore('user', () => {
  const firstName = ref('')
  const lastName = ref('')
  const email = ref('')
  const bearerToken = ref('')
  const uid = ref('')
  const client = ref('')
  const accessToken = ref('')

  function signIn(user, headers) {
    firstName.value = user.firstName
    lastName.value = user.lastName
    email.value = user.email
    bearerToken.value = headers.bearerToken
    uid.value = headers.uid
    client.value = headers.client
    accessToken.value = headers.accessToken
  }
  function signOut() {
    firstName.value = ''
    lastName.value = ''
    email.value = ''
    bearerToken.value = ''
    uid.value = ''
    client.value = ''
    accessToken.value = ''
  }
  return { firstName, lastName, email, bearerToken, uid, client, accessToken, signIn, signOut }
  }
)