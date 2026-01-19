import { Elm } from './Main.elm';
import './style.css';

const root = document.querySelector('#app');
Elm.Main.init({ node: root });
