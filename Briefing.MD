# Mission Briefing: Lok-On Greece Dynamic Playground

## Overview
**Lok-On Greece Dynamic Playground** is a persistent, dynamic PvP multiplayer mission. 
Two coalitions (**RED** vs **BLUE**) compete for total map control.
The ultimate objective is to capture all airbases and Forward Arming and Refueling Points (FARPs) across the theatre.
 
**Theatre:** Caucasus

---

## Objectives
- **Primary Goal:** Capture and hold all Airbases and FARPs on the map. In total 31 (Bases, FARPS, FOBs and Factories)
- **Logistics & Economy:** Utilize the CTLD system to purchase, transport, and deploy troops and vehicles. Control over logistics is essential to pushing the frontline and maintaining defenses.
- **Victory Condition:** Achieving total control of all Airbases, FARPs, and Factories will initiate a **5-minute victory countdown**. If your coalition maintains control of all zones until the countdown expires, you win the mission.
---

## Locations

### Airbases
The following major airbases are active and feature logistics loadzones:
- Batumi
- Beslan (Red on start)
- Sukhumi
- Sochi
- Maykop (Blue on start)
- Mozdok
- Nalchik
- Krymsk (Blue Main Base)
- Senaki
- Tsiblishi (Red Main Base)

Note the map has some extra minor airpbases that need to be captured but do not offer logistics support.

## Weapon Restrictions
Advanced weapons and FOX 3 missiles are only available in the main base of each coalition (Krymsk and Tsiblishi).
Additionally, Mineralnye Vody and Gudauta start off as neutral and when captured offer an Forward Main Base for the captor that contains advanced weaponry and slots in its wearhouse.

### FARPs (Forward Arming and Refueling Points)
The following FARPs are distributed across the map for forward logistics and rearming:
- GH02
- GH30
- FH08
- FH66
- FJ21
- FK72
- EJ08 (Blue on start)
- EJ44
- GJ35
- KM56 (Red on start)
- KQ73

---

## Logistics & Units (CTLD System)

Players can generate and transport units using helicopters or trucks via the CTLD (Complete Transport Logistics and Deploy) system. Units require credits to deploy and must be loaded at designated **Loadzones**.

### Deployable Troops
| Unit Type | Name | Role | Cost | Size |
| :--- | :--- | :--- | :--- | :--- |
| **Infantry** | Infantry | Assaulters/Occupiers | §50 | 4 |
| **MANPADS** | Anti-Air | Light Air Defense | §100 | 1 |

### Deployable Vehicles
| Unit Type | Name | Role | Cost | Crates |
| :--- | :--- | :--- | :--- | :--- |
| **Gaz-66** | Gaz-66 Truck | Transport | §100 | 1 |
| **M-113** | Scout | Recon/Light Armor | §100 | 1 |
| **JTAC** | JTAC | Lasing & Targeting | §150 | 1 |
| **T-55** | T-55 | Main Battle Tank | §150 | 1 |
| **Shilka** | Shilka | SPAAG Anti-Air | §180 | 1 |
| **Chaparral** | Chaparral | SHORAD Anti-Air | §200 | 1 |
| **EWR** | EWR | Early Warning Radar | §550 | 1 |
| **SA-13** | SA-13 | SHORAD Anti-Air | §400 | 1 |
| **SA-8** | SA-8 | SHORAD Anti-Air | §400 | 1 |
| **Leopard** | Leopard | Main Battle Tank | §400 | 1 |
| **SA-15M1** | SA-15M1 | Mobile SAM | §1550 | 2 |
| **SA-15M2** | SA-15M2 | Mobile SAM | §1800 | 2 |
| **SA-10** | SA-10 | Heavy Long-Range SAM | §10000 | 4 |

### Logistics Airframes & Transport Details
Transport capabilities depend on the airframe:
- **UH-1H:** 6 Troops or 1 Cargo Crate (Slingload/Internal)
- **Mi-24P:** 6 Troops or 1 Cargo Crate (Slingload/Internal)
- **Mi-8MTV2:** 12 Troops or 1 Cargo Crate (Slingload/Internal)
- **CH-47Fbl1:** 31 Troops or 2 Cargo Crates (Slingload/Internal)
- **Gaz-66 (Truck):** 6 Troops or 2 Cargo Crates
- *Note: AH-64D and OH-58D are combat-only and cannot carry troops or CTLD crates.*

---

## Coalition Budgets & Economy
Each side has a persistent bank balance. Purchasing units via CTLD draws from your coalition's budget. Secure objectives and hold territory to maintain a steady income flow and afford heavier assets like the SA-10 and Leopard MBTs.

**Income Generation:**
- Each team starts with **2 captured Factories** that generate income every hour.
- There are **3 additional neutral Factories** scattered across the map available for capture, providing extra income to the team that holds them.

### Bank Penalties
Losing player-controlled aircraft incurs a financial penalty for your coalition. These penalties are automatically deducted from your coalition's bank balance.

-   **Aircraft Loss Penalties:**
    -   **Planes:** §100 per lost aircraft.
    -   **Helicopters:** §50 per lost helicopter.
-   **When Penalties Apply:**
    -   Crashing your aircraft.
    -   Ejecting from your aircraft.
    -   Your aircraft being destroyed.
    -   Disconnecting from your aircraft while airborne or not safely on the ground (e.g., moving on a taxiway).
    -   Your pilot being killed in action.
-   **Notifications:** When a penalty is applied, a message will be broadcast to your coalition, detailing the penalty amount and your coalition's updated bank balance.
-   **Insufficient Funds:** If your coalition's bank balance is insufficient to cover a penalty, an error message will be displayed, but the penalty will still be recorded.

### Zone Control & Victory Conditions
- **Zone Status Display:** The current status of all zones (RED, BLUE, CONTESTED, NEUTRAL) is displayed in-game after any ownership change, showing: `ZONE CONTROL: RED [count] | BLUE [count] | CONTESTED [count] | NEUTRAL [count] (of [total])`.
- **Contested Zones:** If units from both RED and BLUE coalitions are present in a zone, it becomes **CONTESTED** (yellow on the map) and cannot be captured until one side clears out the other.
- **Total Domination Countdown:** When one coalition captures *all* Airbases, FARPs, and Factories on the map, a **5-minute (300 seconds) victory countdown** will begin.
    -   A warning message will be broadcast to all players, indicating which side has achieved total domination and the remaining time to respond.
    -   **To prevent defeat:** The opposing coalition must capture at least one zone before the countdown expires.
    -   **Victory:** If the dominating coalition maintains control of all zones until the countdown completes, they achieve total battlefield domination and win the mission.
---

## Rules for Capturing Zones
To take control of an Airbase, FARP, or Factory, teams must adhere to the following capture mechanics:
- **Minimum Presence:** At least **4 troops or units** must cross into the objective zone to initiate a capture.
- **Uncontested Capture:** If no opposition forces are present in the zone, the zone will change hands to the capturing coalition.
- **Contested State:** If enemy presence enters the zone while you are capturing or holding it, the objective becomes **contested** and cannot change hands until cleared.
- **Garrison Requirement:** Coalitions are required to keep **at least 1 unit** inside the zone at all times. If left completely empty, the zone will revert to a **neutral** state.
