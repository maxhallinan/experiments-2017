const canvas1 = document.getElementById('canvas1');
canvas1.height = 360;
canvas1.width = 360;
const ctx1 = canvas1.getContext('2d');

const canvas2 = document.getElementById('canvas2');
canvas2.height = 360;
canvas2.width = 360;
const ctx2 = canvas2.getContext('2d');

const canvas3 = document.getElementById('canvas3');
canvas3.height = 360;
canvas3.width = 360;
const ctx3 = canvas3.getContext('2d');
ctx3.strokeStyle = '#222';
const a = Math.floor((360 / 2) - (31 / 2)) + 0.5;
console.log(a);
ctx3.strokeRect(a, a, 31, 31);



// for (var i = 0; i < 8; i++) {
//   var x = i * 60;
//   var y = i * 60;

//   ctx.fillStyle = i % 2 === 0 ? '#fff' : '#222';
//   ctx.fillRect(x, y, x + 60, y + 60);
// }
 
var grid = [ 
  [1,2,3,4,5,6,7,8], 
  [1,2,3,4,5,6,7,8], 
  [1,2,3,4,5,6,7,8], 
  [1,2,3,4,5,6,7,8], 
  [1,2,3,4,5,6,7,8], 
  [1,2,3,4,5,6,7,8], 
  [1,2,3,4,5,6,7,8], 
  [1,2,3,4,5,6,7,8], 
];

var chars = [ 
  "15163861".split(''),
  "44575151".split(''),
  "63861263".split(''),
  "87151630".split(''),
  "60294824".split(''),
  "97130189".split(''),
  "83097152".split(''),
  "63861511".split(''),
].map((xs) => xs.map(Number));

var chars1 = "c899e780ded33f4ab30228212112a33ad349e3052c838f10ad6a3fc946928ef3".split('')
chars1 = chars1.reduce((cs, c, ind) => {
  var current = cs[cs.length - 1];

  if (current.length < 8) {
    cs[cs.length - 1].push(c);
  } else {
    cs.push([c])
  }

  return cs;
}, [[]]);

var empties1 = []; 

var renderedTeeth = false;

for (var i = 0; i < chars1.length; i++) {
  var row = chars1[i];
  var y = i * 45;

  for (var j = 0; j < row.length; j++) {
    var cell = row[j];
    var x = j * 45; 

    var isEmpty = cell.charCodeAt(0) % 2;

    if (isEmpty) {
      empties1.push([x,y]);

      // if (Math.random() % 2 === 0 && !renderedTeeth) {
      //     ctx.fillStyle = '#ddd';
      //     ctx.fillRect(x, y, 60, 60);
      // }
    }

    var fill = isEmpty ? '#fff' : '#111';

    // if (isEvenRow) {
    //   fill = isEvenCol ? '#fff' : '#222';
    // } else {
    //   fill = isEvenCol ? '#222' : '#fff';
    // }

    ctx1.fillStyle = fill;

    ctx1.fillRect(x, y, 45, 45);
  }
}

// ctx.strokeStyle = '#222'
// ctx.strokeRect(10.5, 10.5, 30, 30);

var chars2 = "424ddf0b6bfc3932e24a83d65f4a50f6746ef2708c4d207931048d79ed06b040".split('')
chars2 = chars2.reduce((cs, c, ind) => {
  var current = cs[cs.length - 1];

  if (current.length < 8) {
    cs[cs.length - 1].push(c);
  } else {
    cs.push([c])
  }

  return cs;
}, [[]]);

var empties2 = [];

for (var i = 0; i < chars2.length; i++) {
  var row = chars2[i];
  var y = i * 45;

  for (var j = 0; j < row.length; j++) {
    var cell = row[j];
    var x = j * 45; 

    var isEmpty = cell.charCodeAt(0) % 2;

    if (isEmpty) {
      empties2.push([x,y]);

      // if (Math.random() % 2 === 0 && !renderedTeeth) {
      //     ctx.fillStyle = '#ddd';
      //     ctx.fillRect(x, y, 60, 60);
      // }
    }


    var fill = isEmpty ? '#fff' : '#111';

    // if (isEvenRow) {
    //   fill = isEvenCol ? '#fff' : '#222';
    // } else {
    //   fill = isEvenCol ? '#222' : '#fff';
    // }

    ctx2.fillStyle = fill;

    ctx2.fillRect(x, y, 45, 45);

    if (!isEmpty) {
      ctx2.strokeStyle = '#eee';
      ctx2.beginPath();
      ctx2.arc(31, 31, 50, 0, 2 * Math.PI);
      ctx2.stroke();
    }
  }
}

setInterval(function () {
  function getRandomInt(max) {
    return Math.floor(Math.random() * Math.floor(max));
  }

  const [x1, y1] = empties1[getRandomInt(empties1.length)];
  ctx1.strokeStyle = '#222'
  ctx1.strokeRect(x1 + 7.5, y1 + 7.5, 31, 31);
}, 7000);

setInterval(function () {
  function getRandomInt(max) {
    return Math.floor(Math.random() * Math.floor(max));
  }

  const [x2, y2] = empties2[getRandomInt(empties2.length)]
  ctx2.strokeStyle = '#222';
  ctx2.strokeRect(x2 + 7.5, y2 + 7.5, 31, 31);
}, 800);
