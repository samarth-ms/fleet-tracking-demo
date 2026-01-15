# MOBILE_ARCHITECTURE

---

This document focuses on mobile architecture principles and design intent.
Technical details, API contracts, and use-cases are documented separately.

---

# System Architecture

## Context

The app is:

- State-heavy (auth, user, shift, order, sync)
- Long-lived (multi-hour shifts, background work)
- Offline-first
- Event-driven (GPS, sync, admin actions)
- Reactive in nature

UI is short-lived; application state is long-lived.

---

## Why MVVM

- **State-driven UI**  
  UI is a direct projection of observable state. Views react to changes; no imperative UI logic.

- **Decouples UI from app lifecycle**  
  Background events (GPS, sync, session changes) can occur without active screens. ViewModels survive screen recreation.

- **Offline-first friendly**  
  Deterministic state handling and clear separation between persisted state and UI make recovery after restarts predictable.

- **Fits background & system events**  
  Location updates, sync results, and session invalidation propagate naturally without screen coupling.

- **Testable by design**  
  ViewModels contain logic and state, independent of UI.

---

## Why Not MVC / MVP

- MVC leads to logic-heavy controllers tightly coupled to screen lifecycle.
- MVP introduces coordination-heavy presenters and manual handling of async/background events.

Both are a poor fit for long-lived, background-driven state.

---
---

# Platform Selection

## Decision

The Driver mobile application is built using native mobile development (Native Android and iOS).

## Reasoning

The app is system-heavy, with core requirements around:

- Background location tracking
- Geo-fencing
- Offline-first behavior
- Battery-sensitive execution

These capabilities require deep integration with OS-level APIs and predictable lifecycle behavior.

Cross-platform frameworks add abstraction layers that reduce control over background execution and system behavior. They are also primarily UI-oriented, optimized for screen rendering and interaction rather than long-running, system-level responsibilities.

Given the nature of this application, these trade-offs are not favorable.

---
---

# Offline-First Strategy

## Overview

The Driver mobile app is designed with an offline-first mindset.

The system assumes that network connectivity is unreliable and intermittent, and therefore does not treat the network as a prerequisite for normal operation.

The primary goal of the offline-first strategy is to ensure that:

- Driver workflows are never blocked due to lack of connectivity
- No data generated on the device is lost
- Backend consistency is achieved through eventual synchronization

---

## Core Principle

All data generated or collected on the mobile app is first persisted locally, regardless of network state.

This locally stored data is then synchronized with the backend when network connectivity is available.

Locally persisted data is removed only after the backend acknowledges successful receipt.

This principle applies uniformly across:
- User actions
- Operational state changes
- Location and tracking data

---

## Design Implications

- The mobile app is treated as a source of truth for in-progress operations
- Network communication is treated as eventual, not immediate
- Temporary network failures do not affect driver productivity

---
---

# Location Tracking & Battery Optimization

## Core Principle

Location tracking is driven by the driver’s operational state, not by UI state or app visibility.

Tracking is enabled only when the driver is actively performing work (e.g. during an active shift).

Opening the app, navigating screens, or backgrounding the app does not independently start or stop tracking.

This ensures tracking is intentional, predictable, and aligned with business activity.

---

## Tracking Model

Location tracking is treated as a two-part concern:

- **Location collection** — determining where the driver is
- **Tracking and reporting** — persisting and synchronizing collected data

This separation allows tracking behavior to evolve independently from data synchronization and avoids unnecessary coupling.

This section focuses only on the collection part.

---

## Battery Optimization Philosophy

Battery optimization is treated as a first-class architectural concern and not a reactive change.

The system follows these guiding principles:

- **Value-based tracking**  
  Tracking fidelity is proportional to operational relevance. Not all moments during a shift require the same level of precision.

- **Adaptive behavior**  
  Tracking adjusts dynamically based on context rather than relying on fixed settings.

- **State-driven decisions**  
  Tracking behavior is determined by driver state and activity, not UI transitions or screen lifecycle.

- **Battery-aware operation**  
  As battery conditions degrade, tracking behavior is relaxed to prioritize continuity of operation over precision.

---
---

# Data Synchronization Strategy

## Core Principle

Data synchronization is designed to be reliable, non-blocking, and eventually consistent.

The mobile app never assumes continuous connectivity and never couples data collection to network availability.

The app keeps all locally generated data until the backend confirms it has been received.

---

## Approach

The system follows a pipeline-based mindset, not a request-response mindset.

- Data collection and data synchronization are fully decoupled
- Collection always succeeds, regardless of network state
- Synchronization happens opportunistically, not continuously
- Failures are expected and handled as part of normal operation

At no point does synchronization block:

- Location collection
- Driver actions
- Shift progression

---

## Consistency Model

The system is eventually consistent by design.

- The backend converges to the correct state over time
- Temporary delays in synchronization are acceptable
- Data correctness is prioritized over immediacy

Real-time visibility is treated as an enhancement, not a guarantee.

---

## Reliability Over Immediacy

The synchronization strategy prioritizes:
- No data loss
- Explicit acknowledgement
- Safe retries

Data is removed from the device only after the backend confirms successful receipt.
In the presence of failures, data is retained and retried later.

---
---

# Push Notification Architecture

Push notifications are treated as event signals, not as a source of truth or a primary data delivery mechanism.

On the mobile app:

- Notifications are used to prompt user attention or trigger a state refresh
- The app handles notifications consistently across foreground, background, and terminated states
- Duplicate or delayed notifications are handled safely and do not affect correctness

All critical data and state transitions are derived through the app’s standard synchronization flows.

Notification delivery, targeting, and reliability are primarily backend concerns and are therefore out of scope for this design.

---
---

# Real-Time Updates Design

## Overview

The mobile app supports near real-time location updates while preserving battery life and offline resilience.

Real-time behavior is treated as best-effort and never as a correctness requirement.

---

## Core Principle

The latest location is the most valuable real-time signal.

The mobile app prioritizes sending the most recent available location rather than attempting to stream all location updates.

---

## Mobile Behavior

- Location updates are sent opportunistically
- The app prioritizes freshness over completeness
- The app does not attempt continuous streaming
- Gaps and delays in updates are expected under constrained conditions

Real-time updates never block:

- Location collection
- Driver actions
- Offline operation

---

## Non-Goals

Real-time updates do not aim to provide:

- Guaranteed delivery intervals
- Strict ordering
- Continuous background streaming

---

Real-time updates are designed to provide useful, timely signals without compromising battery usage, reliability, or offline-first behavior.

---
