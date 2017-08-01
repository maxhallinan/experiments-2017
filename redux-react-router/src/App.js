import React from 'react';
import { Link, Route, } from 'react-router-dom';

function Nav() {
  return (
    <nav>
      <ul>
        <li><Link to="/">Home</Link></li>
        <li><Link to="/foo">Foo</Link></li>
        <li><Link to="/bar">Bar</Link></li>
        <li><Link to="/baz">Baz</Link></li>
      </ul>
    </nav>
  );
}

function Body(props) {
  const { pageName, } = props;

  return (
    <h1>{pageName}</h1>
  );  
}

function Page(props) {
  const { match, } = props;

  return (
    <Body pageName={match.path} /> 
  );
}

function App() {
  return (
    <div>
      <Nav />
      <Route exact path="/" component={Page} />
      <Route path="/foo" component={Page} />
      <Route path="/bar" component={Page} />
      <Route path="/baz" component={Page} />
    </div>
  );
}

export default App;
