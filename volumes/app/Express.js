const express = require('express');
const promClient = require('prom-client');

const app = express();
const port = 80;

// Create a Registry which registers the metrics
const register = new promClient.Registry();

// Add a default metrics collection
promClient.collectDefaultMetrics({ register });

// Create a custom counter metric
const counter = new promClient.Counter({
  name: 'node_request_operations_total',
  help: 'The total number of processed requests',
  labelNames: ['method']
});

app.get('/', (req, res) => {
  counter.inc({ method: req.method });
  res.send('Hello, world!');
});

app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});

app.listen(port, () => {
  console.log(`Example app listening at http://localhost:${port}`);
});
