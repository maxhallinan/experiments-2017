const compose = (a, b) => x => a(b(x));
const get = prop => src => src[prop];

// impure local storage getter/setters
const setLocalStorage = (k, v) => localStorage.setItem(k, v);
const getLocalStorage = (k) => localStorage.getItem(k);

// transform impure functions into pure ones by delaying evaluation
// https://drboolean.gitbooks.io/mostly-adequate-guide/content/ch3.html#the-case-for-purity
const pureSetLocalStorage = (k, v) => () => setLocalStorage(k, v);
const pureGetLocalStorage = (k) => () => getLocalStorage(k);

// IO's `__value` is always a function
function IO(fn) {
  this.unsafePerformIO = fn;
}

IO.of = function (x) {
  return new IO(() => {
    return x;
  });
};

IO.prototype.map = function (fn) {
  return new IO(compose(fn, this.unsafePerformIO));
}

const proc = IO.of(process);
const env = proc.map(get('env'));
const editor = env.map(get('EDITOR'));

// forces the impurity onto the calling code 
console.log(editor.unsafePerformIO()); // 'vim'
