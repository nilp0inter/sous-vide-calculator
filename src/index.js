import './style.css';
import { Elm } from './Main.elm';

const app = Elm.Main.init({
  node: document.getElementById('app'),
  flags: {
    lang: navigator.language || 'en',
    hash: window.location.hash
  }
});

window.addEventListener('hashchange', () => {
  app.ports.onHashChange.send(window.location.hash);
});