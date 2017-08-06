const kreeater = require('kreeater');

const toggleFoo = kreeater.fromType('TOGGLE_FOO');
toggleFoo();
// { type: 'TOGGLE_FOO', }

const createBar = kreeater.fromType(
  'CREATE_BAR', 
  (author, text) => ({ author, text, }));
const author = 'Oliver Wendell Holmes, Jr.'
const text = 'other tools are needed besides logic';
createBar(author, text);
// {
// 	type: 'CREATE_BAR',
// 	author, 'Oliver Wendel Holmes, Jr.',
// 	text: 'other tools are needed besides logic.',
// }

const destroy = kreeater.fromMap(
	{ foo: 'DESTROY_FOO', bar: 'DESTROY_BAR', baz: 'DESTROY_BAZ', }
	id => ({ id, }));
destroy.foo(1) 
// { type: 'DESTROY_FOO', id: 1, }
destroy.bar(1); 
// { type: 'DESTROY_BAR', id: 1, }
destroy.baz(1);
// { type: 'DESTROY_BAZ', id: 1, }
