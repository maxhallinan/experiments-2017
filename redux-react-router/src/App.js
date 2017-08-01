import React from 'react';
import { connect, } from 'react-redux';
import { Link, Route, } from 'react-router-dom';

function Nav() {
  return (
    <nav>
      <Link to="/">Home</Link>{" "}
      <Link to="/foo">Foo</Link>{" "}
      <Link to="/bar">Bar</Link>{" "}
      <Link to="/baz">Baz</Link>
    </nav>
  );
}

function Body(props) {
  const { pageName, } = props;

  return (
    <h1>{pageName}</h1>
  );  
}

const Home = connect(() => ({ pageName: 'Home'}))(Body);
const Foo = connect(() => ({ pageName: 'Foo'}))(Body);
const Bar = connect(() => ({ pageName: 'Bar'}))(Body);
const Baz = connect(() => ({ pageName: 'Baz'}))(Body);

function App() {
  return (
    <div>
      <Nav />
      <Route exact path="/" component={Home} />
      <Route path="/foo" component={Foo} />
      <Route path="/bar" component={Bar} />
      <Route path="/baz" component={Baz} />
    </div>
  );
}

export default App;
