require('lookup-multicast-dns/global');
const net = require('net');
const jsonStream = require('duplex-json-stream');

const nickname = process.argv[2];
const host = process.argv[3];
const port = process.argv[4];

const connection = net.createConnection(port, host);
const client = jsonStream(connection);

process.stdin.on('data', function (data) {
  client.write({
    msg: data.toString(),
    nickname,
  })
});

client.pipe(process.stdout);
