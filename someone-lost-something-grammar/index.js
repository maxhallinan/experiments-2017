const fs = require('fs');
const tracery = require('tracery-grammar');

const grammar = tracery.createGrammar({
  "person": [
    "Friendly Skull",
    "Pipes",
    "Donovan Roundness",
    "Vernerd",
    "Weepy Weepy" 
  ],
  "thing": [
    "a spell",  
    "a comb",
    "a pair of rolled pants",
    "the last lightbulb",
    "both wool slippers"
  ],
  "utility": [
    "smashing concrete",
    "spellchecking foggy thoughts",
    "scalp scratching",
    "paying the price",
    "finding electrocution risks",
  ],
  "origin": ["#person# lost #thing# for #utility#."]
});

const results = [];

while (results.length < 125) {
  const r = grammar.flatten('#origin#');

  if (results.indexOf(r) === -1) {
    results.push(r);
  }
}

fs.writeFile(
  './results.txt', 
  results.join('\n'), 
  () => console.log('Language has been written to results.txt.')
);
