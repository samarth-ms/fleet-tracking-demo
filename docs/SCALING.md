# SCALING.md

This document outlines how the mobile architecture supports scale while clearly defining the boundaries of mobile responsibility versus backend infrastructure.

The goal is to demonstrate that the mobile app behaves responsibly under scale, without overreaching into backend-specific design decisions.

---

# Handling High Driver Volume (GPS Updates)

The system is designed assuming large fleets (e.g. 10,000+ drivers) sending frequent GPS updates.

From a mobile perspective:
- Location updates are **batched**, not sent individually
- Location collection is **decoupled from network availability**
- Synchronization is **opportunistic**, not continuous
- The **latest location is prioritized** for freshness

These measures significantly reduce:
- Network chatter
- Backend request volume
- Battery consumption

Once batching and freshness prioritization are applied, further scalability concerns (ingestion throughput, fan-out, storage) are primarily **backend responsibilities**.

---

# Battery Optimization at Scale

Battery optimization is treated as a **first-class concern**, especially at scale.

Key principles applied:
- Tracking is **state-driven**, not UI-driven
- Accuracy and frequency are **adaptive**, based on operational relevance
- Background tracking is enabled only during active work
- Battery state influences tracking behavior

These strategies ensure that increased driver count does not linearly increase battery drain across the fleet.

(Refer to `MOBILE_ARCHITECTURE.md` for detailed tracking philosophy.)

---

# Network Optimization

The mobile app applies simple, high-impact network optimizations:

- Batching high-frequency data (e.g. GPS samples)
- Avoiding duplicate or static data in repeated payloads
- Prioritizing freshness over completeness for real-time signals

Advanced techniques such as compression or binary protocols are not required for correctness and are considered backend-driven optimizations if needed at scale.

---

# Backend Infrastructure Assumptions

Backend infrastructure design (e.g. stream processing, horizontal scaling, storage architecture) is **explicitly out of scope** for mobile architecture.

The mobile app assumes that the backend:
- Can ingest batched data
- Supports same write requests without duplication
- Handles eventual consistency
- Acts as the authoritative source of truth

These assumptions allow the mobile app to remain simple and resilient without coupling to specific backend implementations.

---

# Database Design for Mobile Sync

Mobile-side database design is optimized for scale through:

- Durable local persistence
- Append-only queues for offline actions
- Explicit acknowledgment before deletion
- Replayable event models

SQLite is used on both platforms to ensure predictable behavior under large volumes of locally stored data (e.g. GPS samples).

This design ensures that scale does not compromise reliability or data integrity on the device.

---

# CDN Strategy for Map Tiles

The mobile application does not embed a custom map rendering solution.

Even if a map SDK were to be used (e.g. Google Maps, Apple Maps, Mapbox), the mobile app would be **integrating an existing, fully managed mapping solution**, not building or operating a map platform.

In such cases:
- Map tile hosting, caching, and CDN distribution are handled by the map provider
- The mobile app consumes maps as a client and does not control tile delivery
- CDN configuration and optimization remain vendor-managed concerns

As a result, CDN strategy for map tiles is **not a mobile architecture responsibility** and is intentionally out of scope for this design.

---

# Summary

From a mobile architecture perspective, scalability is addressed by:

- Responsible data collection and batching
- Battery-aware tracking strategies
- Clear separation of mobile and backend responsibilities
- Explicit non-goals to avoid unnecessary complexity

This approach ensures the mobile app remains reliable, efficient, and predictable as fleet size grows, while allowing backend systems to scale independently.

---
