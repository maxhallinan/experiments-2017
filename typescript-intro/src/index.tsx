import * as React from 'react';
import * as ReactDOM from 'react-dom';
import App from './App';
import registerServiceWorker from './registerServiceWorker';
import './index.css';

ReactDOM.render(
  <App />,
  document.getElementById('root') as HTMLElement
);
registerServiceWorker();

interface GenericIdentity {
  <X>(x: X): X;
}

const identity: GenericIdentity = x => x;

console.log(identity(1));
