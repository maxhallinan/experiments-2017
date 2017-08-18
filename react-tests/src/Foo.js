/* @flow */
import React from 'react';

type Props = {
  text: string,
};

const Foo = (props: Props) => <p>{props.text}</p>;

export default Foo;
