import React from 'react';
import ReactDOM from 'react-dom';
import { createStore, } from 'redux';
import reducer from './reducer';
import Root from './Root';

const store = createStore(
  reducer,
  window.__REDUX_DEVTOOLS_EXTENSION__ && window.__REDUX_DEVTOOLS_EXTENSION__(),
);

ReactDOM.render(
  <Root store={store} />,
  document.getElementById('root')
);
