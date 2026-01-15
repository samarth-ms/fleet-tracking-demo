# Assumptions

## Purpose

This document captures **explicit assumptions** made during the design of the assignment.

This document intentionally avoids listing:
- Proposed optimizations
- Design decisions
- Obvious platform or industry defaults

---

## 1. Users & Identity

- A driver can only be logged in and operational in **one place at a time**.
- The mobile application is used **only by drivers**.
- Admin users and workflows are handled outside the mobile application.

---

## 2. Account & Authentication

- Driver accounts are **pre-created** and managed by a **separate system**.
- Driver verification is handled externally and is **out of scope** for the mobile app.
- The mobile app does not support self-registration or account creation.
- Login failures due to invalid or unrecognized mobile numbers are possible and must be handled gracefully.

---

## 3. Shift Lifecycle

- Shifts are **assigned by the system/admin**, not created by the driver.
- A shift may exist in an **assigned but not yet active** state.
- A shift becomes active **only after the driver explicitly starts it**.
- Shift start requires the driver to be **physically present at the assigned hub**.
- Only **one shift can be active per driver at any given time**.
- Shifts can be ended **only after the scheduled shift end time**.
- Ending a shift earlier than the scheduled end time requires **admin intervention** and is out of scope for the mobile app.

---

## 4. Hub & Vehicle

- Each shift is associated with **exactly one hub**.
- Vehicles are assumed to be:
  - Picked up from the hub at shift start
  - Returned to the hub at shift end
- Vehicle assignment is completed **before shift start**.
- Vehicle reassignment during an active shift is not considered.

---

## 5. Orders & Fuel Delivery

- The term **Order** is used consistently to represent a delivery task.
- Orders are **pre-assigned** to the shift.
- Order volume per shift is assumed to be **small (tens at most, not hundreds)**.
- Fuel dispensing is assumed to be controlled by **external hardware or systems** that:
  - Regulate fuel flow
  - Ensure only the assigned quantity is dispensed
- The specifics of fuel dispensing hardware, measurement, and validation are **out of scope**.

---

## 6. Location & Connectivity

- Location tracking is required **only while a shift is active**.
- Drivers are expected to operate in environments with **intermittent or unreliable network connectivity**.

---
