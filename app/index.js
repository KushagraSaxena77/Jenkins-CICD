const http = require('http');

const PORT = process.env.PORT || 3000;
const VER = process.env.APP_VERSION || 'v1';

const requestHandler = (req, res) => {
  res.writeHead(200, { 'Content-Type': 'text/plain' });
  res.end(`Hello from demo-app ${VER}!\n`);
};

const server = http.createServer(requestHandler);

server.listen(PORT, () => {
  console.log(`demo-app ${VER} listening on port ${PORT}`);
});
