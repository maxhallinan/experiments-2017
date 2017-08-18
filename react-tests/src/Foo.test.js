import React from 'react';
import ReactDOM from 'react-dom';
import { mount, shallow, } from 'enzyme';
import Foo from './Foo';

/*
 * Testing React components
 *
 * Tests are being run by [Jest](https://facebook.github.io/jest/)
 * Jest provides browser globals like `window` to jsdom
 * Jest does not model browser quirks. Intended for testing logic.
 * Easiest to place the tests next to the code they test.
 * By default, Jest only runs tests related to files changed since the last commit.
 * Jest exposes some global functions: `it`, `test`, and `describe`.
 *  - `it`: wraps a test block. an alias for `test`.
 *  - `describe`: logical grouping of tests
 *
 * Reference:
 * [create-react-app README](https://github.com/facebookincubator/create-react-app/blob/master/packages/react-scripts/template/README.md#running-tests)
 */

/*
 * Start with simple smoke tests. Bugs caused by changing components will
 * provide deeper insight into what should be tested.
 *
 * Full rendering tests will fail if child components throw.
 */
it('renders without crashing', () => {
  const div = document.createElement('div');

  // Basic full rendering
  ReactDOM.render(<Foo text="foo" />, div);
  // or full rendering with enzyme's `mount`
  mount(<Foo />);
});

/*
 * Shallow rendering:
 *
 * Constrains testing to the component itself. Tests do not fail on errors
 * thrown by rendering child components.
 *
 * `yarn add enzyme react-test-renderer` is recommended for shallow rendering.
 */
it('shallow renders without crashing', () => {
  shallow(<Foo text="foo" />);
});

/*
 * Enzyme provides assertion methods that wrap Chai and Sinon.
 */
it('renders the message in a paragraph tag', () => {
  const actual = shallow(<Foo text="Hello World!" />);
  const expected = <p>Hello World!</p>;
  expect(actual.contains(expected)).toEqual(true);
});

/*
 * There is an Enzyme extension called jest-enzyme that provides more 
 * convenient Jest matchers.
 * `jest-enzyme` imported in `./setupTests.js`
 */

it('renders the message in a paragraph tag (Jest matcher)', () => {
  const actual = shallow(<Foo text='Hello World!' />);
  const expected = <p>Hello World!</p>;

  expect(actual).toContainReact(expected);
});
