export const ROUTE_CHANGE = 'ROUTE_CHANGE';

export function routeChange(location, match) {
  return {
    type: ROUTE_CHANGE,
    location,
    match,
  };
}
