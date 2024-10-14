import { createRouter, createWebHistory } from 'vue-router'
import HomeView from '../views/HomeView.vue'
import LoginView from '../views/LoginView.vue'
import ProtectedView from '../views/ProtectedView.vue'
import { useAuthStore } from '@/stores/useAuthStore'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      name: 'home',
      component: HomeView,
      meta: { allowAnonymous: true },
    },
    {
      path: '/login',
      name: 'login',
      component: LoginView,
      meta: {
        allowAnonymous: true,
        rejectAuth: true,
      },
    },
    {
      path: '/protected',
      name: 'protected',
      component: ProtectedView,
    },
  ],
})

router.beforeEach(async (to, _from, next) => {
  const auth = useAuthStore()

  await auth.waitForLoad()

  if (to.meta.rejectAuth && auth.isAuthenticated) {
    return next({ name: 'home' })
  }

  if (!to.meta.allowAnonymous && !auth.isAuthenticated) {
    return next({ name: 'login' })
  }

  next()
})

export default router
