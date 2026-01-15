# OFFLINE_STRATEGY.md

This document describes how the Driver mobile application behaves under intermittent or unavailable network conditions.

The offline strategy is designed to ensure:
- Driver workflows are never blocked due to connectivity
- No operational data is lost
- Backend state converges correctly once connectivity is restored

This document focuses on **behavior and intent**, not implementation details.

---

# Offline vs Online Capabilities

## Offline Capabilities

The following features are available when the device is offline:

- Remain logged in with an existing valid session
- Access cached user identity and role
- View today’s shift (cached)
- View assigned vehicle (cached)
- View list of assigned orders (cached)
- View order details (cached)
- View last known delivery order / route
- Complete an order
- Fail an order
- Capture GPS location updates
- Store GPS data locally
- Associate GPS data with shift and active order
- Launch external navigation apps
- Continue tracking while navigation is active
- See offline mode indication
- See pending sync status
- Continue normal app flow without network

Offline mode is treated as a **normal operating condition**, not an error state.

---

## Online-Only Capabilities

The following features require active network connectivity:

- First-time login
- Session refresh after expiry or revocation
- Receive new shifts
- Receive order updates or reassignments
- Receive admin-forced changes
- Sync queued order actions to backend
- Upload GPS data batches
- Receive sync acknowledgements
- Receive conflict resolution outcomes
- Real-time location visibility for admins
- End shift
- Push notifications

---

# Queue Management

## Local-First Persistence

All actions performed by the driver are persisted locally first, regardless of network state.

- Actions are recorded immediately
- Actions are timestamped and immutable
- Actions are added to a durable offline queue

The app never relies on in-memory state alone for recoverable operations.

---

## Synchronization Triggers

Synchronization is attempted when:
- Network connectivity becomes available
- The app enters an active state
- Background sync opportunities arise

Synchronization never blocks:
- UI interactions
- Driver workflows
- Location collection

---

## Ordering & Freshness

Different data types have different synchronization priorities.

### Location Data

- **Freshness is prioritized**
- The **latest location sample is sent first**
- This ensures near real-time visibility as soon as connectivity returns
- Older location samples are synced afterward for completeness and audit purposes

The system optimizes for:
- Immediate visibility of current driver position
- Eventual completeness of historical location data

---

### Operational Actions (Orders)

- Order related actions are synced in **logical order**
- Ordering is preserved within each action type
- APIs are designed so repeated requests can be safely retired

This ensures operational consistency without blocking newer actions.

---

## Acknowledgment & Retry Model

- Actions are removed from the local queue **only after explicit backend acknowledgment**
- Failed or delayed sync attempts result in retries
- Duplicate submissions are expected and safe

The mobile app assumes retries are a normal part of operation.

---

# Conflict Resolution

## Backend-Authoritative Model

Conflict resolution is handled entirely by the backend.

The mobile app:
- Records what happened
- Includes timestamps and relevant context
- Does not attempt to resolve conflicts locally

The backend:
- Evaluates events using timestamps, assignment state, and business rules
- Determines the authoritative outcome
- Returns the resolved state to the client

---

## Example Scenario

**Scenario:**  
A driver completes an order offline while an admin reassigns the same order.

**Resolution:**
- The offline completion is synced when connectivity is restored
- The backend evaluates assignment state and timing
- The backend decides the final outcome
- Affected drivers are notified of state changes
- The mobile app reconciles state through normal sync and fetch flows

The mobile app always defers to backend decisions.

---

# User Feedback During Offline Mode

## Offline Awareness

The app clearly communicates offline state to the driver:

- Offline mode indicator
- Pending sync status
- Sync in progress indication when connectivity returns

Offline mode is communicated as an **expected condition**, not a failure.

---

## Sync Feedback

Drivers receive feedback for:
- Pending actions awaiting sync
- Successful synchronization
- Blocking failures (e.g. session invalidation)

Transient sync failures are handled silently.  
Only actionable issues are surfaced to the user.

---

# Summary

The offline strategy ensures that:
- Driver productivity is not impacted by network availability
- All actions and data are captured safely
- Freshness is prioritized where it matters (location tracking)
- Backend state converges correctly over time
- User experience remains predictable and trustworthy

This approach reflects real-world operating conditions for fleet and logistics applications.

---
