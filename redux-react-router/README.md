# redux-react-router

Using [React Router 4](https://reacttraining.com/react-router/web/guides/philosophy) 
with Redux.

## Notes

- Two sources of truth:
  - Redux: data source of truth;
  - React Router: URL source of truth.
- Put React Router state into the Redux store when you need time travel debugging
  for route transitions.
  - [react-router-redux](https://www.npmjs.com/package/react-router-redux): 
    keeps router in sync with redux store for time travel debugging.

## Links

**Documentation**

- [Redux: Usage with React Router](http://redux.js.org/docs/advanced/UsageWithReactRouter.html)

**You can't render a connected component between Router and Route**

- [Gitub: React Router 4 (beta 8) won't render components if using redux connect #4671](https://github.com/ReactTraining/react-router/issues/4671)
- [Medium: How to safely use React context](https://medium.com/@mweststrate/how-to-safely-use-react-context-b7e343eff076)
- [Twitter: "Redux implements sCU, making setState + context break..."](https://twitter.com/ryanflorence/status/779320581678174208)

## Usage

```
# install create-react-app
npm install -g create-react-app@1.3.3
yarn install
yarn start
```
