# The Softanza Delivery Plane
### From a solution's definition to running on real targets — one continuous program

> This is the map. Each area below links to its design doc and a runnable tutorial.
> The plane sits on the [System Foundation](../narrations/stz-system-dev-to-deploy-narration.md)
> and is Scope-Oriented Programming's third instance
> ([SCOPE_ORIENTED_PROGRAMMING.md](SCOPE_ORIENTED_PROGRAMMING.md) §7).

---

## What it is

A real product spans machines — a phone app, a backend, a microcontroller — and in
most stacks the journey from editor to running device is a scramble of disconnected
tools: an IDE, a Dockerfile, a CI YAML, a cross-compiler, a flash script, a cloud
console. Each holds one slice of the truth; the gaps between them are where "it
worked on my machine" is born.

The **delivery plane** models that whole journey as **one object graph in one
vocabulary** — so a solution goes from *defined* to *emulated* to *deployed on real
targets* as a single continuous program, every stage inspectable, every commit
governed.

## The thesis

- **Compile the engine, not the interpreter.** The browser runs Softanza's
  *differential compute* as WebAssembly (`stz.wasm`) — the same Zig logic that backs
  the native DLLs — not a Ring VM. The edge carries only what the platform is weak
  at; JS-strong capabilities (Unicode, regex, dates) defer to the platform.
- **One vocabulary, editor to device.** The same delivery planner that plans the solution
  drives the build, the emulator, and the deployment.
- **Expression is free; admission is governed.** Any actor can *rehearse* any plan;
  only an *effectful* actor may commit. An LLM can design a whole rollout and change
  nothing.

## The pipeline

```
  define ─▶ require ─▶ emulate ─▶ describe ─▶ feasibility ─▶ plan ─▶ execute ─▶ ship
   (caps)   (resources) (real     (sites as   (fit, or       (steps,  (real       (artifacts,
                         engine)   configs)    provision)     gated)   commands)   byte-for-byte)
  └──────────────────────────────── governed at every commit ────────────────────────────────┘
```

## The components

| Object | Role |
|---|---|
| `stzDelivery` | describe the solution (parts, targets, capabilities) and **rehearse the placement plan** — per capability, on its target, a delivery vector and *why* |
| `stzBuildPlan` | the rehearsed plan; `Explain()` prints the whole rationale |
| `stzBuilder` + `build.zig wasm` | cross-compile the parts; emit each part's **engine subset** as `stz_<part>.wasm` (`zig build wasm -Dwasm-groups=…`) |
| `stzEmulator` | **`Deploy(:Emulated)`** — the web mission-control where each part runs its *real* engine and is debugged, part by part |
| `stzDeploymentSite` | a **config-described target** — connection / storage / protocol / control, plus capacity and provider |
| `stzResourceSpec` | one shape, two roles — a part's **requirement** and a host's **capacity** |
| `stzDeployment` | **`Deploy(:Production)`** — bind parts to sites, plan the ordered steps, check feasibility, provision, execute through live backends, ship artifacts — transactional and governed |
| `stzSystemActor` | the **governance crossing** — who may commit (`Can("effectful")`) |
| `stzSecret` (+ `stzAuth`) | **confidential values** — a site's key redacts itself in every config and reveals only to an effectful actor (an LLM rehearsing can reference it, never read it) |

## Two phases of one verb

Deployment is Scope-Oriented: the *phase* is the scope, and one verb serves both.

```ring
oDelivery.Deploy(:Emulated)     # rehearse in the browser -- each part runs its real engine
oDelivery.Deploy(:Production)   # commit to real sites -- the same parts, the same scope, governed
```

Emulation is where you find out it works; production is where the *same* parts, at
the *same* scope, go live — because they were always the same code and the same
artifacts. The very bundle you emulated wires straight into a production attach.

## The document map

Each area has a **design doc** (the why + how) and a **runnable tutorial** (real
code, real output):

| Area | Design | Tutorial |
|---|---|---|
| **Emulation** — the programming-phase surface; per-part `stz.wasm` subsets; the differential edge | [SOFTANZA_EMULATION.md](SOFTANZA_EMULATION.md) | [emulating the whole solution](../narrations/stz-emulating-the-whole-solution-narration.md) |
| **Deployment — sites** — config-described targets; governance; dual-phase `Deploy` | [SOFTANZA_DEPLOYMENT.md](SOFTANZA_DEPLOYMENT.md) | [deploying to the target sites](../narrations/stz-deploying-to-target-sites-narration.md) |
| **Deployment — plan & provisioning** — the ordered/gated/reversible step DAG; host resources, feasibility, provisioning | [SOFTANZA_DEPLOYMENT_PLAN.md](SOFTANZA_DEPLOYMENT_PLAN.md) | [planning and provisioning a deployment](../narrations/stz-planning-and-provisioning-a-deployment-narration.md) |
| **Secrets & credentials** — confidential values that redact themselves, resolve lazily, and reveal only under governance; user auth | [SOFTANZA_SECRETS.md](SOFTANZA_SECRETS.md) | [guarding secrets and credentials](../narrations/stz-guarding-secrets-and-credentials-narration.md) |

Background: the [Scope-Oriented Programming](SCOPE_ORIENTED_PROGRAMMING.md) paradigm
(the target platform as the invisible frame), and the
[System Foundation](../narrations/stz-system-dev-to-deploy-narration.md) it stands on
(named scopes, capability profiles, the governance crossing).

## What's proven, and what's reach

Every layer is provable in-repo and exercised by the narrated guards
(`emulator_narrated`, `wasm_narrated`, `delivery_narrated`,
`deployment_narrated`, `secret_narrated`). The two layers that touch the outside world for real — the
**git backend** and the **compiled wasm** — are proven end to end. `ssh` / `aws` and
the other providers generate correct commands and run through the same managed
child; they are one reachable host or account away from literal, not a gap in the
machinery.

---

*The delivery plane's whole point: the distance from "defined in my editor" to
"running on the target" is one legible, governed program — so "it worked in
emulation" and "it's live in production" are the same sentence.*
