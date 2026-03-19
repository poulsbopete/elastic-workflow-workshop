---
marp: true
theme: default
paginate: true
header: "What's New in Elastic Search 9.3"
footer: "Peter Simkins · Elastic"
style: |
  section { font-size: 28px; }
  h1 { font-size: 1.4em; }
  table { font-size: 0.85em; }
---

<!-- _class: lead -->
# What's New in Elastic Search **9.3**

**Peter Simkins** — Senior Solutions Architect · Elastic

---

# Workshop agenda

| Theme | Capability | Outcome |
|-------|------------|---------|
| **Simplify** | ES\|QL · LOOKUP JOIN · Workflows | Readable queries · One query vs many API calls · Visual automation |
| **Optimize** | Inference endpoint | Native automation vs external glue |
| **Innovate with AI** | Agent Builder · ELSER | Ask in English · Search by meaning |

From multiple API calls → **single-query efficiency**  
From complex external tools → **native automation**  
From keyword matching → **semantic understanding**

---

# Today's core philosophy

> **Search** finds the insight.  
> **Workflows** act on it.  
> **Agent Builder** explains it.

- **Simplify:** ES\|QL + Workflows  
- **Optimize:** Automated response  
- **Innovate with AI:** Natural language investigation

---

# Today's format

**Four sections × two parts**

| Segment | Time | What |
|---------|------|------|
| **Presentation** | ~5 min | Concepts + live demo — the *why* and *how* |
| **Workshop** | ~10 min / section | Hands-on challenges in the lab |

---

# The challenge: review bombing

**Review bombing** — coordinated fake negative reviews to manipulate reputation.

Applies everywhere:

- **Restaurants:** Yelp, Google, TripAdvisor  
- **E-commerce:** Amazon, Walmart, Home Depot  
- **Apps:** App Store, Google Play  
- **B2B:** G2, Capterra, Trustpilot  

*Erodes consumer trust one fake star at a time.*

---

# The high cost of fake reviews

- **Platform churn** — users leave when they see fake narratives  
- **Revenue** — ~**5–9%** loss per 1-star drop  
- **Scale** — millions of reviews; **manual triage** cannot keep pace with automated attacks  

Review integrity is a **financial imperative**, not just a data annoyance.

---

# Workshop journey

1. **Detection logic** — Correlate review content with **user trust scores** (ES\|QL)  
2. **Workflow** — Scheduled run (~every 5 min) orchestrates **hold + protect + incident**  
3. **AI investigation** — **Agent Builder** tools for natural language analysis  
4. **Simulation** — End-to-end **attack → detect → respond → resolve**

---

# Know your data

**Yelp-style dataset (Philadelphia subset)**

- ~**100** businesses · ~**76K** users · ~**149K** reviews  
- **Indices:** `businesses`, `users`, `reviews`, `incidents`, `notifications`  

**Trust score (example thresholds)**

- **Low** (&lt; 0.3) — new / suspicious accounts  
- **High** (&gt; 0.7) — established contributors  

*Goal: defend real businesses from coordinated attacks.*

---

# Time to get hands-on

**Simplify, optimize, innovate with AI**

1. Open your **workshop environment** (link from facilitator — lab window is limited)  
2. **Mission:**  
   - **Detect** a review bomb  
   - **Contain** it automatically  
   - **Generate** an incident-style narrative with AI tools  

> Search finds. Workflows act. Agent Builder explains.

---

# Challenge 1 — Know your data

**Detection logic:** correlate reviews with **trust scores**.

**Activities**

- Data model · explore indices  
- Trust scores · review patterns  
- **Semantic search** · **LOOKUP JOIN** enrichment  

Write **ES\|QL** (with joins) to spot coordinated low-trust bursts.

---

# Simplify detection with ES\|QL

Traditional queries can be **verbose**.  

**ES\|QL** uses **pipes** so you hunt attacks in a clear, linear flow — readable by analysts and ops, not only search experts.

---

# The power of LOOKUP JOIN

**One query** correlates reviews with **user reputation** (and businesses) — no round-trips through your app for every enrichment.

---

# Challenge 2 — Workflows

**Activities**

- Build an **automated workflow** that detects a **negative review campaign** and **responds in real time**  
- Understand **triggers**, **ES\|QL steps**, and **actions** (hold reviews, protect business, write `incidents`)

Scheduled execution (~**5 min**) orchestrates the response.

---

# Optimize response with Workflows

**Automate** takedown / hold paths and **enrich** context for analysts.

**Workshop goal:** workflow that **holds** attack reviews and **creates** an incident record.

---

# Automated response (example pattern)

**Trigger (example)**  
- ≥ **15** low-trust **1-star** reviews in **&lt; 1 minute**

**Actions**  
1. Reviews marked **Held**  
2. Business marked **PROTECTED**  
3. Displayed rating **frozen** (e.g. **4.5** stars) while you investigate  

*Tune thresholds to your environment.*

---

# Challenge 3 — Agent Builder

**Activities**

- Background on **tools** vs **agents**  
- Create **tools** (ES\|QL / data access)  
- Create an **agent** that investigates campaigns: summarize incidents, attacker patterns, similar malicious reviews  

**Innovate:** ask in **plain English**.

---

# Innovate — investigate with Agent Builder

Deploy an agent **grounded in your own indices** to produce **Who / What / Where / When / Why / How** style answers.

---

# Challenge 4 — End-to-end scenario

**Activities**

- **ElasticEats** UI · baseline stats  
- **Launch** the attack  
- Watch **workflow** detection  
- **Investigate** with your agent  
- **Resolve** the incident  

Full **detect → contain → explain** loop.

---

# Today's core philosophy (recap)

> **Search** finds the insight.  
> **Workflows** act on it.  
> **Agent Builder** explains it.

**Simplify · Optimize · Innovate with AI**

---

# Thank you & Q&A

**Slides & code:** [elastic/elastic-workflow-workshop](https://github.com/elastic/elastic-workflow-workshop)  

**Contact:** peter.simkins@elastic.co · **Labs:** use the window your facilitator provides.

**More workshops** — ask your Elastic team for Search / Observability / Security tracks. **Q&A** — advanced vs intro — we can point you to the right next step.
