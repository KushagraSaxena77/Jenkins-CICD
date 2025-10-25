const http = require('http');
<<<<<<< HEAD

const PORT = process.env.PORT || 3000;

const requestHandler = (req, res) => {
  res.writeHead(200, { 'Content-Type': 'text/plain' });
  res.end('Hello from demo-app!\n');
};

const server = http.createServer(requestHandler);

server.listen(PORT, () => {
  console.log(`demo-app listening on port ${PORT}`);
});
=======
const port = process.env.PORT || 3000;
const ver = process.env.APP_VERSION || "v1";
http.createServer((req, res) => {
  res.end(`Hello from demo app ${ver}\n`);
}).listen(port, () => console.log(`Listening ${port}`));
>>>>>>> 9eac8d7a082bd601510aacec7907fc0f38a7e069
