import React from 'react';
import { Provider, } from 'react-redux';
import { BrowserRouter as ReactRouter, } from 'react-router-dom';
import App from './App';

function Root({ store, }) {
  return (
    <Provider store={store}>
      <ReactRouter>
        <App />
      </ReactRouter>
    </Provider>
  );
}

export default Root;
