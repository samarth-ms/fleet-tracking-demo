# API_DESIGN.md

---

# Mobile-Optimized API Contracts

This document defines the API surface from a **mobile-first perspective**.  
The focus is on clarity, reliability, retry-safety, and offline compatibility rather than exhaustive backend design.

All APIs are designed assuming:
- Intermittent connectivity
- Retries and duplicate requests
- Background execution
- Eventual consistency

---

## API Setup (Mobile Perspective)

### Base Setup
- Mobile app communicates with a **single API base endpoint**
- Environment-based configuration (dev / staging / prod)
- All APIs are **authenticated by default**, except login-related calls

---

### Common Request Headers

All API requests include a consistent set of headers for identity, compatibility, and observability.

**Authentication**
- `Authorization` – access token for authenticated requests

**Client Context**
- `X-App-Version` – mobile app version
- `X-Platform` – iOS / Android
- `X-Device-Id` – stable device identifier
- `X-Request-Id` – unique request identifier for tracing

**Time Context**
- `X-Client-Timestamp` – event time on device (used for ordering and reconciliation)

**Content**
- `Content-Type`
- `Accept`

---

### API Versioning

- APIs are **explicitly versioned**
- Versioning is applied at the API level (URL or header)
- Breaking changes require a new version
- Older clients fail gracefully with clear signals when unsupported

---

### Mobile Expectations

- APIs are **retry-safe and idempotent**
- Requests are treated as **stateless**
- Backend does not rely on request order

---

## API Contracts

### Authentication & Session

#### Request OTP  
**POST** `/auth/otp/request`

```json
{
  "phoneNumber": "+91XXXXXXXXXX"
}
```

```json
{
  "success": true
}
```

---

#### Verify OTP / Login  
**POST** `/auth/otp/verify`

```json
{
  "phoneNumber": "+91XXXXXXXXXX",
  "otp": "123456"
}
```

```json
{
  "accessToken": "string",
  "refreshToken": "string",
  "driver": {
    "driverId": "string",
    "name": "string",
    "hubId": "string"
  }
}
```

---

#### Refresh Session  
**POST** `/auth/session/refresh`

```json
{
  "refreshToken": "string"
}
```

```json
{
  "accessToken": "string"
}
```

---

#### Logout  
**POST** `/auth/logout`

```json
{
  "success": true
}
```

---

### Driver & Profile

#### Fetch Driver Profile  
**GET** `/driver/profile`

```json
{
  "driverId": "string",
  "name": "string",
  "phoneNumber": "string",
  "hub": {
    "hubId": "string",
    "name": "string",
    "latitude": 0.0,
    "longitude": 0.0
  }
}
```

---

### Shift Management

#### Fetch Assigned Shift  
**GET** `/shifts/current`

```json
{
  "shiftId": "string",
  "status": "ASSIGNED | ACTIVE | ENDED",
  "scheduledStart": "ISO-8601",
  "scheduledEnd": "ISO-8601",
  "actualStart": "ISO-8601 | null",
  "actualEnd": "ISO-8601 | null",
  "vehicleId": "string"
}
```

---

#### Start Shift  
**POST** `/shifts/{shiftId}/start`

```json
{
  "timestamp": "ISO-8601"
}
```

```json
{
  "status": "ACTIVE"
}
```

---

#### End Shift  
**POST** `/shifts/{shiftId}/end`

```json
{
  "timestamp": "ISO-8601"
}
```

```json
{
  "status": "ENDED"
}
```

---

### Vehicle

#### Fetch Assigned Vehicle  
**GET** `/vehicles/assigned`

```json
{
  "vehicleId": "string",
  "registrationNumber": "string",
  "type": "string"
}
```

---

### Orders (Deliveries)

#### Fetch Assigned Orders  
**GET** `/orders?shiftId={shiftId}`

```json
[
  {
    "orderId": "string",
    "destination": {
      "type": "HUB | TERMINAL",
      "name": "string",
      "latitude": 0.0,
      "longitude": 0.0
    },
    "products": [
      {
        "productType": "DIESEL | PETROL",
        "quantityGallons": 0
      }
    ],
    "status": "PENDING | COMPLETED | FAILED"
  }
]
```

---

#### Fetch Order Details  
**GET** `/orders/{orderId}`

```json
{
  "orderId": "string",
  "destination": {
    "type": "HUB | TERMINAL",
    "name": "string",
    "latitude": 0.0,
    "longitude": 0.0
  },
  "products": [
    {
      "productType": "DIESEL | PETROL",
      "quantityGallons": 0
    }
  ],
  "status": "PENDING | COMPLETED | FAILED"
}
```

---

#### Update Order Status (Complete / Fail)  
**POST** `/orders/{orderId}/status`

```json
{
  "status": "COMPLETED | FAILED",
  "timestamp": "ISO-8601"
}
```

```json
{
  "success": true
}
```

---

### Location & Tracking

#### Send Location Updates (Latest or Batched)  
**POST** `/locations`

```json
{
  "locations": [
    {
      "latitude": 0.0,
      "longitude": 0.0,
      "timestamp": "ISO-8601",
      "shiftId": "string",
      "orderId": "string | null"
    }
  ]
}
```

```json
{
  "accepted": true
}
```

---

### Sync

#### Sync Queued Actions  
**POST** `/sync/actions`

```json
{
  "actions": [
    {
      "actionId": "string",
      "type": "ORDER_STATUS_UPDATE | SHIFT_END",
      "payload": {},
      "timestamp": "ISO-8601"
    }
  ]
}
```

```json
{
  "processedActionIds": ["string"],
  "conflicts": [
    {
      "actionId": "string",
      "reason": "string"
    }
  ]
}
```

---
---

# Payload Size Considerations (Mobile)

Payload optimization is applied pragmatically and only where it provides clear value.

Principles
- Batch high-frequency events (e.g. location updates)
- Avoid sending unnecessary or unused data
- Do not repeat static data within batched payloads
- Keep payload structures simple and predictable

Advanced optimizations (e.g. binary formats, compression) are intentionally not prioritized, as they add complexity and are typically justified only at much larger scale.

---
---

# API Versioning Approach

From a mobile perspective, API versioning is treated as a backend compatibility concern.
- Mobile apps target a specific API version per release
- No runtime version negotiation is performed
- Breaking changes are handled via new app releases
- Unsupported versions are signaled clearly by the backend

The mobile app assumes a stable API contract for its lifetime.

---
---

# Handling Offline Queues & Sync Conflicts

The mobile app allows actions to be performed offline and queues them locally for synchronization.

When connectivity is restored:
- Queued actions are synced to the backend
- Each action includes the time at which it occurred on the device

In conflict scenarios (e.g. an order completed offline while being reassigned):
- The backend acts as the source of truth
- Conflict resolution is based on timestamps, assignment state, and business rules
- The backend determines the authoritative outcome
- Affected drivers are notified of resulting changes
- Mobile apps reconcile state through normal fetch and sync flows

The mobile app does not attempt to resolve conflicts locally.  
Its responsibility is to reliably capture intent and align with backend state once connectivity is available.

---
