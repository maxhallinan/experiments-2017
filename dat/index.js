const Dat = require('dat-node');

Dat('/home/max/Projects/TestDat', (err, dat) => {
  if (err) {
    console.log(`Top level err: ${err}`);
    return;
  }

  const importer = dat.importFiles({ watch: true, });

  dat.joinNetwork();

  dat.network.on('connection', () => {
    console.log(`Connected to the network.`);
  });

  console.log('My Dat link is: dat://', dat.key.toString('hex'));
});
