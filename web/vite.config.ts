import { fileURLToPath, URL } from 'node:url'

import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

export default defineConfig(({ mode }) => {
  let config = {
    build: {
      outDir: 'dist'
    },
    server: {
      port: 3000,
      host: '0.0.0.0',
      proxy: {
        '/api': {
          target: 'http://api:4000',
          chngeOrigin: true
        },
        '/oauth': {
          target: 'http://api:4000',
          chngeOrigin: true
        },
        '/swaggerui': {
          target: 'http://api:4000',
          chngeOrigin: true
        }
      }
    },
    plugins: [vue()],
    resolve: {
      alias: {
        '@': fileURLToPath(new URL('./src', import.meta.url))
      }
    }
  }

  if (mode === 'production') {
    config.build.outDir = '../server/priv/static'
  }

  return config
})
