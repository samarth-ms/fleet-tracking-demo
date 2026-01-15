# TECHNICAL_DECISIONS.md

This document captures the key technical decisions made while designing the mobile architecture for the Driver application.  
The focus is on **why** specific approaches and technologies were chosen, rather than on implementation details.

---

# Native vs Cross-Platform

## Decision

The Driver mobile application is implemented using **native mobile development** (iOS for the prototype).

## Rationale

The app is **system-heavy**, with core responsibilities around:

- Background location tracking
- Geo-fencing
- Offline-first operation
- Battery-sensitive behavior
- Long-lived execution across app lifecycle states

These requirements depend heavily on **deep integration with OS-level APIs** and predictable system behavior, which are best supported by native platforms.

Cross-platform frameworks are primarily **UI-oriented** and introduce abstraction layers that reduce control over background execution and system behavior. For this use case, those trade-offs are not favorable.

Only iOS is implemented for the prototype, while keeping the architecture platform-agnostic and applicable to Android using native equivalents.

---
---

# State Management & Local Storage Strategy

## State Management Approach

In native mobile applications, state management is not handled through external libraries such as Redux or MobX.  
Instead, state is managed through **clear ownership boundaries** across services, domain models, and ViewModels.

- Core application state (session, shift, orders, tracking, sync) is owned by long-lived services and domain models
- ViewModels observe and expose state to the UI
- UI is treated as a projection of state and remains stateless
- Background and foreground flows operate on the same underlying state
- Persisted state is restored on app restart to ensure continuity

This approach aligns naturally with MVVM and avoids introducing unnecessary global state frameworks.

---

## Secure Storage (Keychain / Keystore)

Sensitive data is stored using platform-provided secure storage.

**Used for:**
- Access tokens
- Refresh tokens
- Driver identifier
- Minimal session metadata

**Decision:**
- iOS: Keychain  
- Android: Keystore / EncryptedSharedPreferences  

Secure storage is used exclusively for secrets and authentication-related data.

---

## Local Database

Structured, operational data is persisted using a local database.

**Used for:**
- Shift state
- Orders
- Offline action queue
- Location samples
- Sync bookkeeping

**Decision: SQLite (on both platforms)**

- iOS: SQLite (via Core Data or direct SQLite)
- Android: SQLite (via Room)

**Rationale:**
- Native availability on both platforms
- Predictable behavior under offline and background conditions
- Well-suited for relational, durable, and replayable data
- No vendor lock-in or hidden runtime behavior

---
---

# Map SDK Choice

## Decision

No in-app map SDK is included as part of the mobile application.

---

## Rationale

The core responsibility of the driver app is **location collection and operational tracking**, not navigation or route visualization.

Navigation is a solved problem with widely adopted external solutions. Many large-scale mobility and logistics apps (e.g. Uber) delegate navigation to external apps such as Google Maps rather than fully re-implementing routing and navigation inside their own apps.

Drivers can optionally open an external navigation app if they are unsure of the route. During navigation, the driver app can move to the background while continuing to collect location data independently via OS location services.

---

## Business & Cost Considerations

Embedding a map or navigation SDK typically introduces **usage-based pricing**, especially when using:
- Map rendering
- Directions / routing APIs
- Distance or traffic services

At scale, these costs can grow significantly without directly contributing to the core value of the driver app.

By delegating navigation to external apps:
- No map rendering or routing APIs are required
- No map SDK billing is incurred
- Operational and infrastructure costs remain predictable

This provides a clear cost advantage while still giving drivers access to best-in-class navigation when needed.

---

## Summary

Avoiding an in-app map SDK:
- Reduces ongoing operational cost
- Avoids duplicating mature navigation solutions
- Keeps the app focused on tracking and delivery execution

This approach aligns with both business efficiency and industry practice.

---
---

# Authentication & Session Management

## Overview

Authentication follows an **OAuth 2.0–style, token-based model**, tailored for a first-party mobile application.

The backend acts as the authorization server, while the mobile app acts as a secure client consuming issued tokens.  
The mobile app does not manage authentication logic and relies entirely on backend-issued sessions.

---

## Authentication Model

- Authentication is mobile number–based using OTP
- OTP verification acts as the authorization grant
- Driver accounts are pre-created and validated by backend systems
- Successful verification results in token issuance

The mobile app does not:
- Create accounts
- Determine driver eligibility
- Manage OTP lifecycle

---

## Session Model

- Sessions are token-based, following OAuth principles
- Backend is the single authority on session validity
- Each driver can have only one active session at a time
- Sessions are bound to:
  - Driver identity
  - Device identifier

A new login implicitly revokes any existing session for the same driver.

---

## Token Strategy

- **Access Token**
  - Short-lived
  - Used for all authenticated API requests

- **Refresh Token**
  - Long-lived
  - Used to obtain new access tokens
  - Revoked on logout or forced invalidation

Token refresh is handled transparently by the app.

---

## Mobile Responsibilities

The mobile app is responsible for:
- Secure storage of tokens
- Attaching access tokens to API requests
- Refreshing access tokens when required
- Responding to authorization failures

The mobile app does not:
- Validate tokens locally
- Resolve session conflicts
- Maintain multiple active sessions

---

## Failure & Revocation Handling

- Authorization failures are treated as authoritative
- On token invalidation:
  - Local session state is cleared
  - User is redirected to login
- No local recovery is attempted for invalid sessions

---

## Summary

Authentication and session management follow a backend-driven, OAuth-style token model.  
This enables revocable sessions, single-device enforcement, and consistent identity handling while keeping mobile-side logic minimal.

---
