# LODP Tactical Playbook

Two coalition plans for maximizing early income, building a defensible front, and pushing toward SA-10/SA-15 deployment.

---

## Economics Reference

| Source | Income | Notes |
|--------|--------|-------|
| Blue Factory 1 | §100/hr | Blue at start |
| Red Factory 1 | §100/hr | Red at start |
| Blue Factory 2 | §150/hr | Neutral — Blue-side approach |
| Red Factory 2 | §150/hr | Neutral — Red-side approach |
| Neutral Factory | §250/hr | Neutral — contested centre |
| **All 5 factories** | **§750/hr** | One side holds all |
| Zone capture bonus | §100 flat | Per zone flipped (~20 neutral zones = §2,000 max) |
| Safe landing bonus | §10 flat | Fixed-wing only, friendly base |

Income ticks every **60 minutes**. Starting bank: **§10,000** per coalition.

### Heavy SAM Cost vs Income

| Asset | Cost | Crates | Time to save at §200/hr net | Time at §400/hr net |
|-------|------|--------|-----------------------------|---------------------|
| SA-15M1 | §1,550 | 2 | ~8 hrs | ~4 hrs |
| SA-15M2 | §3,000 | 3 | ~15 hrs | ~7.5 hrs |
| SA-10 | §10,000 | 4 | never | never |

These numbers assume you're already broke after garrisoning. **The only realistic path to SA-10 is preserving most of your starting §10,000 while income covers ongoing costs.** That requires a specific spending discipline described in each plan below.

---

## Logistics Reference

| Platform | Troops | Crates | Critical note |
|----------|--------|--------|---------------|
| UH-1H / Mi-24P | 6 | 1 | Good for single-zone ops and FARP logistics runs |
| Mi-8MTV2 | 12 | 1 | Primary assault transport |
| CH-47Fbl1 | 31 | 2 | Mass capture ops; 1 sortie = SA-15M2 delivery |
| **C-130J-30** | **36** | **7** | **Strategic airlift: delivers SA-10 (4 crates) in 1 sortie** |
| Gaz-66 truck | 6 | 2 | Ground logistics on safe roads |

The C-130 is the only platform that can deliver an entire SA-10 system in a single sortie (4 crates). Planning a C-130 mission to the SA-10 site while still saving budget is how SA-10 actually gets deployed in a session.

---

## Universal Principles

**Garrison discipline**: A zone reverts to neutral the instant it empties. Every captured zone needs at least 1 unit inside permanently. An empty zone donated back to the enemy costs you §100 capture bonus plus their §100 capture bonus received — a §200 swing.

**FARP activation**: A captured FARP does nothing until you unpack a **FARP Logistics** crate (§50) inside it. Without it, pilots can't rearm forward. Add an **Ammo truck** (§25) alongside for sustained high-tempo ops.

**Aircraft economy**: An F-16/FA-18/MiG-29S lost costs §150. Two lost jets cancel an entire hour of factory income. Safe landing earns §10. Fly as if every sortie costs your coalition money — because it does.

**The Neutral Factory (§250/hr) is a force multiplier**: Holding it for 4 hours earns §1,000 more than if the enemy holds it (your §250 gain plus their §250 loss = §500/hr swing). Over a 5-hour session, this is the difference between affording an SA-10 or not.

---

## Strong Presence Benchmark

A zone is **secure** when it has this minimum garrison stack:

| Unit | Role | Cost |
|------|------|------|
| 4× Infantry (1 group) | Zone holding, minimum capture reversal resistance | §50 |
| 1× Shilka | Kills helicopters and slow movers at low altitude | §180 |
| 1× T-55 | Hard target for CAS; survives MANPADS runs | §150 |

Total per zone: **§380**. This is the baseline. Any key airbase on the frontline should also have:

| Unit | Role | Cost |
|------|------|------|
| 1× SA-8 or SA-13 | Medium-range IR SAM, threats jets at low alt | §400 |
| 1× JTAC | Enables precision CAS from fixed-wing players | §150 |

Full strong-presence stack per key node: **§930**. Budget roughly §5,000–6,000 to garrison 6 frontline airbases to this standard.

**SAM layering progression** (build in this order per node):

```
Shilka (§180) → SA-8/SA-13 (§400) → SA-15M1 (§1,550) → SA-15M2 (§3,000) → SA-10 (§10,000)
```

Shilka alone denies helicopters. SA-8/SA-13 forces jets to medium altitude. SA-15M1 makes medium altitude dangerous. SA-15M2 is a genuine threat to any aircraft in the zone. SA-10 denies an entire map sector.

---

## BLUE Coalition Plan

**Starting assets:** §10,000, Krymsk (Main Base — FOX-3), Maykop (airbase + loadzone), EJ08 + EJ58 (FARPs), Blue Factory 1 (§100/hr).

**Loadzones available at start:** Maykop, Krymsk, EJ08, EJ58.

**Geographic advantage:** Blue's Black Sea coastal corridor runs from Krymsk south through Sochi → Sukhumi/Gudauta → Senaki → Batumi. These airbases form a chain reachable by short helo hops. Capturing them quickly locks Red out of the entire western map.

---

### Phase 1 — Income & Bonus Rush (0–60 min)

**Goal:** Secure Blue Factory 2 + Neutral Factory (§500/hr income), capture 10+ zones for §1,000+ in bonuses, finish the hour with bank above §9,000.

**Spending discipline**: Infantry and FARP logistics only. No vehicles yet. Every §150 T-55 bought now delays SA-10 by 45 minutes of income.

**Heli #1 — Factory sprint:**
1. Load 12 infantry (3 groups, §150) at Maykop.
2. Capture Blue Factory 2. Drop 4 troops, leave 4 as garrison. Carry 4 to nearest neutral FARP.
3. Deliver FARP Logistics (§50) to that FARP. Activate it.
4. Return, reload 12 infantry (§150), continue down the coastal chain capturing airbases (Sochi, then Sukhumi).
5. Each airbase captured: drop 4 troops, keep moving. Garrison is minimal but enough to hold.

**Heli #2 — Neutral Factory:**
1. Load 12 infantry (§150) at Krymsk or Maykop.
2. Fly direct to Neutral Factory (§250/hr). Drop all 12 troops to ensure a strong hold (3 groups = 12 soldiers).
3. The Neutral Factory is the single highest-value target on the map. Garrison it with 12 troops and never let it go empty.
4. Return and run FARP Logistics to FARPs EJ44 and GJ35 on the way.

**Heli #3 — Gudauta grab (Forward Main Base):**
1. Load 8 infantry (§100) at Krymsk.
2. Capture Gudauta. Gudauta unlocks FOX-3 missiles from the western side of the map — massive reduction in combat aircraft ferry time.
3. Leave 4 troops as garrison. This is enough for now.

**Phase 1 budget:**
| Item | Qty | Cost |
|------|-----|------|
| Infantry groups | 8 | §400 |
| FARP Logistics | 3 | §150 |
| Total spend | | §550 |
| Capture bonuses (~10 zones) | | +§1,000 |
| Hour 1 income (§500/hr) | | +§500 |
| **Bank after Hour 1** | | **~§10,950** |

You finish Hour 1 richer than you started, with §500/hr income locked in.

---

### Phase 2 — Building the Strong Presence (60–120 min)

**Goal:** Apply the garrison standard to 6 frontline zones, deploy first SA-15M1, keep bank above §8,000 for SA-10 runway.

**Priority order for garrison builds (use income, not starting capital):**
1. **Neutral Factory**: Add 1× T-55 (§150) and 1× Shilka (§180) — protect this §250/hr asset.
2. **Gudauta**: 1× T-55 (§150) + 1× Shilka (§180) — Forward Main Base must hold.
3. **Sukhumi**: 1× Shilka (§180) — coastal chokepoint.
4. **Senaki**: 1× Shilka (§180) — once captured, adds southern anchor.

**First SA-15M1 deployment (§1,550, 2 crates):**
- Place at Gudauta or Neutral Factory — whichever is under more threat.
- Deliver via CH-47 (2 crates in 1 sortie) or 2× Mi-8 sorties.
- SA-15M1 at Gudauta means enemy jets approaching from the east face a real SAM. Combined with Shilka, it forces high-altitude profiles where FOX-3 from Gudauta has the advantage.

**Phase 2 spending target:**
| Item | Qty | Cost |
|------|-----|------|
| T-55 | 3 | §450 |
| Shilka | 4 | §720 |
| SA-15M1 | 1 | §1,550 |
| FARP Logistics / Ammo trucks | 4 | §250 |
| **Total Phase 2 spend** | | **§2,970** |
| Hour 2 income (§500/hr) | | +§500 |
| Capture bonuses (~5 more zones) | | +§500 |
| **Bank after Phase 2** | | **~§8,980** |

Bank stays near §9,000. SA-10 is within one savings window.

---

### Phase 3 — SA-15M2 Layer and Frontline Push (120–180 min)

**Goal:** Deploy SA-15M2 at the central node, push toward Nalchik and Mozdok, begin saving hard for SA-10.

**SA-15M2 deployment (§3,000, 3 crates):**
- Best placement: **Maykop** (central base, covers the Nalchik approach corridor).
- Deliver via 1× C-130 sortie (7 crate capacity — can carry SA-15M2's 3 crates and 4 extra).
- Or 2× Mi-8 sorties (1 crate each, 2 trips).
- Combined with EWR (§550): SA-15M2 + EWR at Maykop creates a mid-map A2/AD bubble that makes Red's push toward the coast very costly.

**EWR placement (§550):**
- Place at Maykop alongside SA-15M2. EWR feeds targeting data — SA-15M2 is significantly more effective with EWR support.
- Second EWR at Gudauta if budget allows.

**Push toward Nalchik:**
- Nalchik is the frontline hinge. Capturing it cuts Red's east-west corridor.
- Deliver 2× Leopard (§800) + 2× Infantry (§100) via CH-47 to Nalchik.
- Garrison standard: Leopard + Shilka + T-55. Hard to dislodge without coordinated air + ground.

**Phase 3 spending target:**
| Item | Qty | Cost |
|------|-----|------|
| SA-15M2 | 1 | §3,000 |
| EWR | 1 | §550 |
| Leopard | 2 | §800 |
| Infantry for Nalchik | 2 groups | §100 |
| Shilka for Nalchik | 1 | §180 |
| **Total Phase 3 spend** | | **§4,630** |
| Hour 3 income (§500/hr) | | +§500 |
| **Bank after Phase 3** | | **~§4,850** |

Bank drops significantly. From here, spend nothing non-essential. Accumulate for SA-10.

---

### Phase 4 — SA-10 Window (180–300 min)

**Goal:** Accumulate §10,000 while holding the frontline, then deploy SA-10 via C-130.

**Spending freeze**: Hours 3–5 should see minimal new purchases. Only Ammo trucks (§25) and replacement infantry if a zone is contested. Every Shilka bought delays SA-10 by 54 minutes at §500/hr income.

**Income accumulation (§500/hr, ~§200/hr net after minimal upkeep):**

| Hour | Bank |
|------|------|
| End of Hour 3 | ~§4,850 |
| End of Hour 4 | ~§5,350 |
| End of Hour 5 | ~§5,850 |

If you secured all 5 factories (§750/hr) the picture improves:

| Hour | Bank (§750/hr, §200/hr upkeep = §550/hr net) |
|------|------|
| End of Hour 3 | ~§5,400 |
| End of Hour 4 | ~§5,950 |
| End of Hour 5 | ~§6,500 |
| End of Hour 6 | ~§7,050 |
| End of Hour 7 | ~§7,600 |
| End of Hour 8 | ~§8,150 |
| **End of Hour 9** | **~§8,700 — within one big capture bonus push of SA-10** |

Capture bonuses from continued zone flips (enemy territory) accelerate this further. Each contested enemy zone recaptured adds §100.

**SA-10 deployment (§10,000, 4 crates):**
- **Delivery: 1× C-130 sortie** (7 crate capacity handles the full 4-crate SA-10 load with 3 crates to spare — combine with an SA-15M1 delivery in the same flight).
- Best placement: **Krymsk** for strategic western coverage, or **Maykop** for central coverage that covers the entire frontline.
- Pair with existing EWR. SA-10 without EWR is significantly degraded.
- Surround SA-10 with 2× Shilka + 1× SA-8 as close-in protection. A §10,000 investment destroyed by 4 infantry is the most painful outcome in the game.

---

## RED Coalition Plan

**Starting assets:** §10,000, Tsiblishi/Tbilisi-Lockini (Main Base — FOX-3), Beslan (airbase + loadzone), GH30 + KM56 (FARPs), Red Factory 1 (§100/hr).

**Starting position:** Red and Blue are economically symmetric — both start at §100/hr and §10,000 bank. The difference is geographic: Red's main base (Tsiblishi) sits in the southeast, isolated from the centre of the map. Every extra minute in transit is a minute not capturing zones or garrisoning. Red compensates with proximity to Mineralnye Vody (central Forward Main Base) and Red Factory 2.

**Geographic advantage:** Mineralnye Vody is Red's most important early objective — it provides FOX-3 access from the centre of the map and acts as a forward logistics hub. Securing it in Phase 1 cuts Red's combat aircraft ferry time by 5–10 minutes per sortie for the rest of the session.

---

### Phase 1 — Income Blitz (0–60 min)

**Goal:** Secure Red Factory 2 + Neutral Factory (§500/hr income), capture 10+ zones, finish with bank above §10,500. Losing the Neutral Factory to Blue creates a §250/hr gap that compounds every hour — this is the single highest-priority objective on the map.

**Heli #1 — Neutral Factory sprint (highest priority for Red):**
1. Load 12 infantry (§150) at Beslan.
2. Fly direct to Neutral Factory. Drop ALL 12 troops. Red should hold this with a heavier garrison than Blue would — it's Red's most critical economic capture and Blue will contest it.
3. Return immediately and reload 8 infantry (§100).
4. Capture nearest neutral FARP (GH02 or FH08). Deliver FARP Logistics (§50). Activate it.

**Heli #2 — Red Factory 2 + Mineralnye Vody:**
1. Load 12 infantry (§150) at Beslan.
2. Capture Red Factory 2 (§150/hr). Drop 4 troops, keep moving.
3. Continue to Mineralnye Vody. This is Red's Forward Main Base — FOX-3 access from the centre of the map. Drop 8 troops to capture and hold.
4. Mineralnye Vody cuts Red's ferry time to the frontline by 5–10 minutes per sortie.

**Heli #3 — Mozdok:**
1. Load 8 infantry (§100) at Beslan.
2. Capture Mozdok. This northern node blocks Blue's eastern advance and gives Red a northern anchor.
3. Leave 4 troops. Activate Mozdok's loadzone for future forward logistics.

**Phase 1 budget:**
| Item | Qty | Cost |
|------|-----|------|
| Infantry groups | 10 | §500 |
| FARP Logistics | 3 | §150 |
| Total spend | | §650 |
| Capture bonuses (~10 zones) | | +§1,000 |
| Hour 1 income (§500/hr after captures) | | +§500 |
| **Bank after Hour 1** | | **~§10,850** |

Red finishes Phase 1 richer than it started — identical economic position to Blue.

---

### Phase 2 — Building the Strong Presence (60–120 min)

**Goal:** Apply garrison standard to 6 frontline nodes, deploy first SA-15M1 at Mineralnye Vody, keep bank above §8,500.

**Priority garrison builds (from Hour 1 income):**
1. **Neutral Factory**: 1× T-55 (§150) + 1× Shilka (§180) — must not fall.
2. **Mineralnye Vody**: 1× T-55 (§150) + 1× Shilka (§180) — Forward Main Base protection.
3. **Red Factory 2**: 1× Shilka (§180) — income source, easy helo target.
4. **Mozdok**: 1× Shilka (§180) — northern anchor.

**First SA-15M1 (§1,550, 2 crates):**
- Place at Mineralnye Vody. Central position covers the widest arc of the map.
- Combined with Shilka at the same site: helicopters and low-altitude jets face two layers.
- Deliver via CH-47 (2 crates in 1 sortie).

**Phase 2 spending target:**
| Item | Qty | Cost |
|------|-----|------|
| T-55 | 3 | §450 |
| Shilka | 4 | §720 |
| SA-15M1 | 1 | §1,550 |
| FARP Logistics / Ammo trucks | 4 | §250 |
| **Total Phase 2 spend** | | **§2,970** |
| Hour 2 income (§500/hr) | | +§500 |
| Capture bonuses | | +§300 |
| **Bank after Phase 2** | | **~§8,680** |

---

### Phase 3 — SA-15M2 and Western Pressure (120–180 min)

**Goal:** SA-15M2 at Nalchik, begin push toward Senaki, maintain saving discipline for SA-10.

**SA-15M2 (§3,000, 3 crates):**
- Placement: **Nalchik** or **Mineralnye Vody** (central coverage).
- Deliver via 1× C-130 sortie from Beslan or Mineralnye Vody (once it has a loadzone).
- EWR (§550) alongside SA-15M2 to extend detection range. Together they form a credible medium-range A2/AD bubble covering the central map.

**Push toward Senaki:**
- Senaki is Blue's hinge between the western coast and the interior.
- Insert 2× Leopard (§800) + 2× infantry (§100) + 1× Shilka (§180) via CH-47.
- If Senaki falls, Blue's Batumi and Gudauta are isolated from northern resupply.

**Phase 3 spending target:**
| Item | Qty | Cost |
|------|-----|------|
| SA-15M2 | 1 | §3,000 |
| EWR | 1 | §550 |
| Leopard | 2 | §800 |
| Infantry + Shilka | — | §280 |
| **Total Phase 3 spend** | | **§4,630** |
| Hour 3 income (§500/hr) | | +§500 |
| **Bank after Phase 3** | | **~§4,550** |

---

### Phase 4 — SA-10 Window (180–300 min)

**Goal:** Save to §10,000 while holding Nalchik and Mineralnye Vody, deploy SA-10 via C-130.

Red is now on an identical economic track to Blue. The same saving discipline applies: spend only on Ammo trucks (§25) and replacement infantry. With §500/hr income and ~§150/hr minimal upkeep, net gain is §350/hr.

| Hour | Bank (§350/hr net, start §4,550) |
|------|----------------------------------|
| End of Hour 4 | ~§4,900 |
| End of Hour 5 | ~§5,250 |
| End of Hour 6 | ~§5,600 |
| End of Hour 7 | ~§5,950 |

With all 5 factories (§750/hr, §200/hr upkeep = §550/hr net):

| Hour | Bank |
|------|------|
| End of Hour 4 | ~§5,100 |
| End of Hour 5 | ~§5,650 |
| End of Hour 6 | ~§6,200 |
| End of Hour 7 | ~§6,750 |
| End of Hour 8 | ~§7,300 |
| **End of Hour 9** | **~§7,850 — within striking range of SA-10** |

**Red's fast-track**: Raid and flip Blue Factory 1 at Maykop (§100/hr). That one capture pushes Red to §600/hr and adds another §250 net per hour advantage over Blue. A helicopter insertion into Maykop is worth more than capturing two neutral FARPs combined.

**SA-10 deployment:**
- **Delivery: 1× C-130 from Mineralnye Vody or Beslan** (4 crates, single sortie).
- Best placement: **Mineralnye Vody** (covers the full Nalchik–Sukhumi corridor) or **Mozdok** (northern coverage).
- Protect with 2× Shilka + 1× SA-8 + EWR. A lone SA-10 dies to a coordinated infantry raid.

---

## Counter-Strategy Notes

**If enemy captures the Neutral Factory first:**
- Immediately contest it. Land 4 troops inside the zone to force a contested state (yellow). They cannot capture until they clear your troops.
- Even 10 minutes of denial is worth §42. An hour of harassment while you build elsewhere costs them §250.

**If enemy deploys SA-15M2 before you:**
- SEAD the EWR first — SA-15M2 without radar is near-blind. Then use terrain masking at low altitude.
- Send a Leopard column to assault the site directly. Ground forces defeat SAMs; air suppression enables the approach.

**Protecting your SA-10:**
- Never deploy SA-10 alone. Minimum protection: 2× Shilka + 1× SA-8 + 1× EWR at the same zone.
- Position it at a zone you already hold strongly, not at a freshly captured forward base.
- A §10,000 SA-10 killed by 4 infantry (§200 to field) is a §10,200 economic disaster.

**If enemy has SA-10 and you don't:**
- SA-10 covers the map at high altitude. SEAD the associated EWR to degrade it.
- Low-altitude terrain-masked approach is survivable for fast jets.
- Ground assault backed by Shilka/Chaparral escort is the most reliable kill method — advance armour to within sight of the site, then destroy.
- Budget your own SA-10 response. The economic war matters more than the individual engagement.
