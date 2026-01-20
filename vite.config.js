import { defineConfig } from 'vite';
import elmPlugin from 'vite-plugin-elm';
import { VitePWA } from 'vite-plugin-pwa';

export default defineConfig({
  plugins: [
    elmPlugin(),
    VitePWA({
      registerType: 'autoUpdate',
      devOptions: {
        enabled: true
      },
      manifest: {
        name: 'Sous Vide Calculator',
        short_name: 'Sous Vide',
        description: 'Baldwin Model Sous Vide Calculator',
        theme_color: '#ffffff',
        icons: [
          {
            src: 'icon.svg',
            sizes: 'any',
            type: 'image/svg+xml',
            purpose: 'any maskable'
          }
        ]
      }
    })
  ],
  base: '/sous-vide-calculator/',
});
