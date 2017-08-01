import { combineReducers, } from 'redux';
import { ROUTE_CHANGE, } from './actions';

const initialState = {
  location: null,
  match: null,
};

const route = (state=initialState, action={}) => {
  const { type, location, match, } = action;

  let nextState = state;

  if (type === ROUTE_CHANGE) {
    nextState = {
      location,
      match,
    };
  }

  return state;
}

export default combineReducers({ route, });
