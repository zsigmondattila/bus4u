import { defineStore } from 'pinia'
import { ref } from 'vue'
import axios from 'axios'

export const userStore = defineStore('user', () => {
  const firstName = ref('')
  const lastName = ref('')
  const email = ref('')
  const companyUid = ref('')
  const authorization = ref('')
  const uid = ref('')
  const client = ref('')
  const accessToken = ref('')

  const session = sessionStorage.getItem('user')
  if(session) resumeSession(JSON.parse(session))

  async function resumeSession(user) {
    accessToken.value = user.accessToken
    let rsp = await axios.get('https://bus4u.fast-table.com/admin/validate_token', { params: { 'uid': user.uid, 'client': user.client, 'access-token': user.accessToken}})
    if(rsp.status == 200){
      signIn(rsp.data.data, rsp.headers)
    }
  }

  function signIn(user, headers) {
    firstName.value = user.firstname
    lastName.value = user.lastname
    email.value = user.email
    companyUid.value = user.company_uid
    authorization.value = headers.authorization
    uid.value = headers.uid
    client.value = headers.client
    accessToken.value = headers['access-token']
    sessionStorage.setItem('user', JSON.stringify({ uid: uid.value, client: client.value, accessToken: accessToken.value }))
  }
  function signOut() {
    sessionStorage.removeItem('user')
    axios.delete('https://bus4u.fast-table.com/admin/sign_out', { params: { 'uid': uid.value, 'client': client.value, 'access-token': accessToken.value}})
      .then(() => {
        firstName.value = ''
        lastName.value = ''
        email.value = ''
        companyUid.value = ''
        authorization.value = ''
        uid.value = ''
        client.value = ''
        accessToken.value = ''
      })
      .catch((err) => console.error(err))
  }
  return { firstName, lastName, email, companyUid, authorization, uid, client, accessToken, signIn, signOut }
  }
)