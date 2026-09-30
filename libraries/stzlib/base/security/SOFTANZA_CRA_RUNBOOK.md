# Softanza -- vulnerability and incident reporting runbook

Closes threat-model risk **R13**. `SECURITY.md` promises that an actively
exploited vulnerability is handled as the EU Cyber Resilience Act (CRA)
requires of a manufacturer. This file is how that promise is kept: who does
what, from which evidence, before which clock runs out.

Written 2026-09-30 by the stzlib-security plane on the author's delegation.
It is an operating procedure, not legal advice: the questions marked
**ASK COUNSEL** are the ones a lawyer settles before the first EU sale.

## 1. Whether the CRA reaches us, and as what

The CRA's reporting obligations (Article 14) apply from **2026-09-11**.

| what ships | our role under the CRA | what that means here |
|---|---|---|
| `stzlib`, free and open source, not monetised | at most an **open-source steward** (Article 24) | report what we learn of an actively exploited vulnerability to the extent we take part in development; this runbook is followed in full anyway -- the cost is the same and the promise in `SECURITY.md` makes no distinction |
| RINGBOL, or any paid Softanza distribution sold in the EU | **manufacturer** | every clock below is a legal duty |

**ASK COUNSEL:** the main establishment that decides which national CSIRT is
our coordinator; whether a non-EU author needs an authorised representative
before the first sale.

## 2. What starts the clock

The clock starts when we **become aware** -- not when we have finished
understanding. Awareness is any one of:

- a private advisory opened at
  `https://github.com/mayouni/stzlib/security/advisories/new` that
  claims exploitation in the wild;
- a detection in `StzDefaultDetectionSet()` or a sentinel alert that a
  customer forwards to us with evidence of exploitation;
- a public report (CVE feed, mailing list, vendored upstream advisory for a
  library listed in `sbom.cdx.json`) that affects a version we ship.

Write the awareness time, in UTC, as the first line of the private advisory.
Every deadline below is counted from it.

## 3. The clocks

Reports go through the **single reporting platform** run by ENISA, which
routes them to the coordinator CSIRT at the same time.

| clock | due | what it contains |
|---|---|---|
| **early warning** | **24 h** from awareness | that an actively exploited vulnerability (or a severe incident) exists in a named product; the member states where the product is sold, if known; for an incident, whether it looks malicious |
| **notification** | **72 h** from awareness | the product and versions; the nature of the exploit and of the vulnerability; the mitigation already available to users, and what they must do; how sensitive the information is |
| **final report** | vulnerability: **14 days** after a fix or mitigation is available -- incident: **one month** after the 72 h notification | description and severity; the root cause where known; the fix; for a vulnerability, what is known of the actor exploiting it |
| **users** | as soon as a mitigation exists | who is affected and what to do, in a form they can act on without reading the advisory (Article 14(8)) |

A report that is late because it was incomplete is still late. Send what is
known at 24 h and at 72 h; the final report is where completeness is owed.

## 4. The procedure

1. **Open the record.** Private GitHub advisory; awareness time on line 1;
   one named person owns it (today: the author).
2. **Preserve the evidence before touching anything.** Where the affected
   system runs Softanza's durable ledger, take a copy of its file and run
   `VerifyDurable()` on the copy: the result says whether the history is
   intact from genesis. Build the timeline with
   `StzIncidentFromCase(...)`: it is the incident's timeline, not a
   reconstruction.
3. **Contain.** The responders in `stzResponsePlan.ring` are the tested
   levers -- lock an account, rotate a secret, revoke a capability, shed a
   source, quarantine an agent -- each proved by a guard under
   `base/test/security/`. Record in the advisory which one was used and
   when; that is the time to contain.
4. **Send the 24 h early warning** (section 3), even if the analysis has
   hardly started.
5. **Fix on a private branch**, add the failing-before guard under
   `base/test/security/` (the plane's rule: no fix without a guard that
   failed before it), and run the full gate:
   `python libraries/stzlib/engine/tools/security_gate.py --full`.
6. **Send the 72 h notification** with the mitigation available so far.
7. **Release.** Push the fix to both remotes; update `sbom.cdx.json` and the
   `VERSION` file if a vendored component moved; publish the advisory with a
   CVE when one is warranted; credit the reporter unless they refuse.
8. **Tell the users** (section 3, last row).
9. **Send the final report** inside its window.
10. **Close the loop in the threat model.** Add the guarantee the fix
    created to `SOFTANZA_THREAT_MODEL.md`, and a line to the estate's
    CONCLUSIONS log.

## 5. What we have not built, said plainly

- **No 24-hour on-call.** One person owns every clock. A report received on
  a day that person cannot act is the realistic way this runbook fails; a
  second named owner is the first thing to add before the first sale.
- **No automatic submission.** The platform is filled in by hand; a Softanza
  report exporter would be a convenience, not a requirement.
- **No signed releases yet** (threat-model R12, deferred by the author for
  the development phase): until they exist, a user cannot tell our fixed
  release from a forged one by signature. It is due before the first release.
