import React from 'react';
import ReactDOM from 'react-dom';
import { 
  branch,
  compose, 
  renderNothing,
  withHandlers, 
  withProps, 
  withState, 
} from 'recompose';


// Utility

const random = (min, max) => Math.floor(Math.random() * (max - min) + min);
const genId = () => random(1, 100000);
const delayPr = (value) => {
  const time = random(500, 1500);
  const isReject = time < 750;

  return new Promise((resolve, reject) => {
    const cb = isReject 
      ? () => reject(new Error('Oops! Something went wrong.')) 
      : () => resolve(value);

    setTimeout(cb, time);
  });
};


// Data

class Collection {
  constructor(collection) {
    this.getItem = this.getItem.bind(this);
    this.getRandomItem = this.getRandomItem.bind(this);
    this.getCollection = this.getCollection.bind(this);

    this.collection = collection; 
    this.idMap = collection.reduce((dict, { id }, index) => {
      dict[id] = index;

      return dict;
    }, {});
  }

  getItem(id) {
    return delayPr(this.collection[this.idMap[id]]);
  }

  getRandomItem() {
    return delayPr(this.collection[random(0, this.collection.length)]);
  }

  getCollection() {
    return delayPr(this.collection);
  }
}

const titles = ['Foo', 'Bar', 'Baz'];

const titlesToThings = title => ({ title, id: genId(), });

const things = new Collection(titles.map(titlesToThings));


// Stateless components 

const Title = ({ title }) => (<h1>{title}</h1>);
const Message = ({ message, }) => (<p>{message}</p>);
const Button = ({ onClick, text, }) => (<button onClick={onClick}>{text}</button>);

const FragmentTitle = branch(
  ({ title }) => !title,
  renderNothing,
)(Title);

const ErrMessage = withProps(({ err, }) => ({ message: err.message, }))(Message);
const Err = branch(
  ({ err }) => !err,
  renderNothing
)(ErrMessage);

const LoadingMessage = withProps(() => ({ message: 'Loading...', }))(Message);
const Loading = branch(
  ({ isLoading, }) => !isLoading,
  renderNothing
)(LoadingMessage);

const Fragment = ({ btnText, err, isLoading, onBtnClick, title, }) => (
  <div>
    <FragmentTitle title={title} />
    <Err err={err} />
    <Loading isLoading={isLoading} />
    <Button onClick={onBtnClick} text={btnText} />
  </div>
);


// Stateful components 

const Thing = compose(
  withState('state', 'setState', (props) => ({
    isLoading: false,
    reqErr: null,
    thing: null,
  })),
  withHandlers({
    getNewThing: ({ getRandomThing, setState, }) => () => {
      setState((state) => ({
        ...state,
        isLoading: true,
        reqErr: null,
        thing: null,
      }));

      getRandomThing()
        .then(thing => setState((state) => ({
          ...state,
          isLoading: false,
          reqErr: null,
          thing,
        })))
        .catch(err => setState((state) => ({
          ...state,
          isLoading: false,
          reqErr: err,
          thing: null,
        })));
    },
  }),
  withProps(({ state, getNewThing, }) => ({
    btnText: 'Refresh',
    err: state.reqErr,
    isLoading: state.isLoading,
    onBtnClick: getNewThing,
    title: state.thing ? state.thing.title : '',
  })),
)(Fragment);


ReactDOM.render(
  <Thing getRandomThing={things.getRandomItem} />,
  document.getElementById('root')
);
