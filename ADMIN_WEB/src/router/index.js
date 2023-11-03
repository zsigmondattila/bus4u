import { createRouter, createWebHistory } from 'vue-router'
import HomeView from '../views/HomeView.vue'
import UserView from '../views/UserView.vue'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/home',
      name: 'home',
      component: HomeView
    },
    {
      path: '/',
      name: 'login',
      component: UserView,
      props: { isLogin: true }
    },
    {
      path: '/register',
      name: 'register',
      component: UserView,
      props: { isLogin: false}
    },
    {
      path: '/schedules',
      name: 'schedule',
      component: HomeView
    },
    {
      path: '/about',
      name: 'about',
      component: HomeView
    },
    {
      path: '/settings',
      name: 'settings',
      component: HomeView
    },
  ]
})

export default router
