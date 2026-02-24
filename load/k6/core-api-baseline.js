import http from 'k6/http';
import { check } from 'k6';

function randomUuidV4() {
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (char) {
    const random = Math.floor(Math.random() * 16);
    const value = char === 'x' ? random : (random & 0x3) | 0x8;
    return value.toString(16);
  });
}

function requiredEnv(name) {
  const value = __ENV[name];
  if (!value || value.trim().length === 0) {
    throw new Error('Missing required environment variable: ' + name);
  }
  return value.trim();
}

const BASE_URL = requiredEnv('BASE_URL').replace(/\/$/, '');
const AUTH_TOKEN = requiredEnv('AUTH_TOKEN');
const CHECKOUT_P95_MS = Number(__ENV.CHECKOUT_P95_MS || 800);
const TRACKING_P95_MS = Number(__ENV.TRACKING_P95_MS || 500);
const CHECKOUT_MIN_RPS = Number(__ENV.CHECKOUT_MIN_RPS || 0.8);
const TRACKING_MIN_RPS = Number(__ENV.TRACKING_MIN_RPS || 1.5);

export const options = {
  discardResponseBodies: true,
  scenarios: {
    checkout: {
      executor: 'constant-arrival-rate',
      exec: 'checkout',
      rate: Number(__ENV.CHECKOUT_RATE || 1),
      timeUnit: '1s',
      duration: __ENV.CHECKOUT_DURATION || '2m',
      preAllocatedVUs: Number(__ENV.CHECKOUT_PREALLOCATED_VUS || 10),
      maxVUs: Number(__ENV.CHECKOUT_MAX_VUS || 30),
    },
    tracking: {
      executor: 'constant-arrival-rate',
      exec: 'tracking',
      rate: Number(__ENV.TRACKING_RATE || 2),
      timeUnit: '1s',
      duration: __ENV.TRACKING_DURATION || '2m',
      preAllocatedVUs: Number(__ENV.TRACKING_PREALLOCATED_VUS || 10),
      maxVUs: Number(__ENV.TRACKING_MAX_VUS || 30),
    },
  },
  thresholds: {
    'http_req_failed{scenario:checkout}': ['rate<0.01'],
    'http_req_duration{scenario:checkout}': ['p(95)<' + CHECKOUT_P95_MS],
    'http_reqs{scenario:checkout}': ['rate>' + CHECKOUT_MIN_RPS],
    'http_req_failed{scenario:tracking}': ['rate<0.01'],
    'http_req_duration{scenario:tracking}': ['p(95)<' + TRACKING_P95_MS],
    'http_reqs{scenario:tracking}': ['rate>' + TRACKING_MIN_RPS],
  },
};

const commonHeaders = {
  Authorization: 'Bearer ' + AUTH_TOKEN,
  'Content-Type': 'application/json',
};

export function checkout() {
  const payload = JSON.stringify({
    userId: randomUuidV4(),
    vendorId: randomUuidV4(),
    currency: 'USD',
    items: [
      {
        menuItemId: randomUuidV4(),
        quantity: 1,
      },
    ],
  });

  const response = http.post(
    BASE_URL + '/api/v1/orders/corporate',
    payload,
    {
      headers: {
        ...commonHeaders,
        'Idempotency-Key': randomUuidV4(),
      },
      tags: { endpoint: 'checkout' },
    }
  );

  check(response, {
    'checkout status is 201': function (res) {
      return res.status === 201;
    },
  });
}

export function tracking() {
  const response = http.get(
    BASE_URL + '/api/v1/deliveries/orders/' + randomUuidV4() + '/tracking',
    {
      headers: commonHeaders,
      tags: { endpoint: 'tracking' },
    }
  );

  check(response, {
    'tracking status is 200': function (res) {
      return res.status === 200;
    },
  });
}
