const http = require('http');
const port = process.env.PORT || 3000;
const ver = process.env.APP_VERSION || "v1";
http.createServer((req, res) => {
  res.end(`Hello from demo app ${ver}\n`);
}).listen(port, () => console.log(`Listening ${port}`));
