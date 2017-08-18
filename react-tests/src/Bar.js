/* @flow */
import React from 'react';
import Foo from './Foo';

type Props = {
  message: string,
};

const Bar = (props: Props) => <Foo text={props.message} />;

export default Bar;
