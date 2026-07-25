const http = require('http');
const httpProxy = require('http-proxy');

const PUBLIC_PORT = process.env.WRAPPER_PORT || 8080;
const TARGET = `http://127.0.0.1:${process.env.API_INTERNAL_PORT || 8081}`;

const proxy = httpProxy.createProxyServer({ target: TARGET, ws: true });

proxy.on('error', (err, req, res) => {
  if (res && res.writeHead && !res.headersSent) {
    res.writeHead(502, { 'Content-Type': 'text/plain' });
    res.end('Bad gateway');
  }
});

const server = http.createServer((req, res) => {
  if (req.url === '/' && (req.method === 'GET' || req.method === 'HEAD')) {
    res.writeHead(302, { Location: '/manager' });
    res.end();
    return;
  }
  proxy.web(req, res);
});

server.on('upgrade', (req, socket, head) => {
  proxy.ws(req, socket, head);
});

server.listen(PUBLIC_PORT, () => {
  console.log(`[wrapper] listening on ${PUBLIC_PORT}, proxying to ${TARGET}, redirecting / to /manager`);
});
