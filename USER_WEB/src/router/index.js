import { createRouter, createWebHistory } from 'vue-router'
import HomeView from '../views/HomeView.vue'
import UserView from '../views/UserView.vue'
import ScheduleView from '../views/ScheduleView.vue'
import StationsView from '../views/StationsView.vue'
import LiveMapView from '../views/LiveMapView.vue'
import AboutView from '../views/AboutView.vue'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      name: 'home',
      component: HomeView
    },
    {
      path: '/login',
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
      path: '/schedule',
      name: 'schedule',
      component: ScheduleView
    },
    {
      path: '/stations',
      name: 'stations',
      component: StationsView
    },
    {
      path: '/live',
      name: 'live',
      component: LiveMapView
    },
    {
      path: '/about',
      name: 'about',
      component: AboutView
    },
    {
      path: '/:notFound(.*)',
      name: 'notFound',
      component: HomeView
    }
  ]
})

export default router
