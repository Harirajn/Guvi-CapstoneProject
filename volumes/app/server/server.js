const express = require('express');
const promClient = require('prom-client');

const app = express();
const register = promClient.register;

// Enable default metrics collection
promClient.collectDefaultMetrics();

// Define a simple route to serve metrics
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});

const PORT = 3000;
app.listen(PORT, () => {
  console.log(`Metrics server listening on port ${PORT}`);
});
