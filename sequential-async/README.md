# sequential-async

```javascript
const getUser = (id) => (dispatch) => {
  dispatch({ type: 'GET_USER_REQUEST', id, });

  return fetchUser(id)
    .then(user => dispatch({ type: 'GET_USER_SUCCESS', id, user, }))
    .catch(err => dispatch({ type: 'GET_USER_ERR', err, }));
};

const getPost = (id) => (dispatch) => {
  dispatch({ type: 'GET_POST_REQUEST', id, });

  return fetchPost(id)
    .then(post => dispatch({ type: 'GET_POST_REQUEST', post, }))
    .catch(err => dispatch({ type: 'GET_POST_REQUEST', err, }));
};
```
