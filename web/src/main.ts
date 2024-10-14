import './assets/main.css'

import { createApp } from 'vue'
import { createPinia } from 'pinia'

import App from './App.vue'
import router from './router'

// import { useAuthStore } from '@/stores/useAuthStore'

const app = createApp(App)

app.use(createPinia())
app.use(router)
//
// const store = useAuthStore()

app.mount('#app')
