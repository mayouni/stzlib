# The Softanza Deployment Plan & Provisioning
### Modelling deployments from the simple to the complex, and sizing the hosts they need

> Status: built. Components: `stzDeployment` (Steps / After / Run / Feasibility),
> `stzResourceSpec`, `stzDeploymentSite` (Capacity / Provider / Provision).
> Guard: `deployment_narrated` (45/45). Part of the
> [deployment technology](SOFTANZA_DEPLOYMENT.md); sits on the governance crossing.

---

## 1. Two things make a deployment hard

Some deployments are one artifact to one place. Others are a *sequence* — provision
the database host, migrate the schema, roll out the backend, smoke-test it, *then*
the frontend that depends on it, and undo everything if a step fails. And every
target must actually *have room*: the memory, compute, and storage the part needs.

So a deployment has two dimensions that CI and IaC languages have long modelled:

- **the plan** — the ordered, gated, reversible sequence of steps (CI job DAGs
  with `needs`, Terraform's resource graph, apply-or-revert);
- **the host resources** — what each unit requires and whether the target provides
  it (Kubernetes `resources.requests` + the scheduler, Terraform `instance_type`
  + providers).

Softanza models both, on top of the plan/apply and approval machinery it already
had (`Explain()` rehearses, `Deploy(:Production)` commits, and only an *effectful*
actor may cross — see [SOFTANZA_DEPLOYMENT.md](SOFTANZA_DEPLOYMENT.md)).

## 2. The plan of steps

A deployment is a **plan of ordered steps**, each an operation on a site:

```
provision  ->  store  ->  launch  ->  verify
```

`Steps()` builds the plan; a **simple** deployment gets that default chain per part,
a **complex** one adds cross-part edges with `After(part, dependsOn)` — turning the
plan into a DAG. A scriptable host inserts a `provision` step first. The steps are
topologically sorted so every dependency precedes its dependants, and `Explain()`
prints the whole thing before a byte moves:

```
  Plan (7 steps, in order; Run() executes them, governed):
     1. provision api -> prod-api
     2. store     api -> prod-api   (after provision:api)
     3. launch    api -> prod-api   (after store:api)
     4. verify    api -> prod-api   (after launch:api)
     5. store     web -> cdn        (after verify:api)   <- the frontend waits for the backend
     6. launch    web -> cdn        (after store:web)
     7. verify    web -> cdn        (after launch:web)

  A verify gate must pass to proceed; a failure rolls back the completed steps.
```

**`Run()`** executes the plan, and gives it the three properties a real rollout
needs:

- **dependencies** — `After(:web, :api)` makes the web frontend's `store` wait for
  the api backend's `verify`; the topological order guarantees it.
- **a gate** — the `verify` step checks the site is actually launched; if it isn't,
  the plan stops.
- **rollback** — any failure rolls the completed `store`/`launch` steps back, in
  reverse (`site.Rollback()`, a `rolledback` status). The deployment is
  **transactional**: a partial rollout undoes itself.

And it is governed the whole way — an LLM actor rehearses every step and commits
nothing; an effectful actor commits. `brain.Deploy(:Production)` drives `Run()`.

## 3. Host resources & provisioning

A part needs resources; a host provides them. Both are one shape —
**`stzResourceSpec`** — used in two roles:

```ring
StzResourcesQ().Memory(2048).Compute(2).Storage(20)   # MB / vCPU / GB
```

- as a **requirement**: `brain.RequiresIn(:api, spec)` — the physical footprint the
  part needs (the parallel to `NeedsIn` for capabilities; the CI/IaC
  `resources.requests` idea).
- as a **capacity**: `site.Capacity(spec)` — what the host provides (declared, or
  for a real host discovered via its provider API).

**Feasibility is `capacity.Meets(sum-of-requirements)`** — the same "does the node
have room?" a Kubernetes scheduler answers. `Feasibility()` reports it per site and
`Feasible()` gates it, as a pre-flight inside `Explain()`, before anything commits:

```
  Host feasibility (required -> capacity):
     [ok  ] prod-api: 2048MB / 2 vCPU / 20GB -> (provision)  (provision on proxmox)
     [ok  ] cdn: 0MB / 0 vCPU / 0GB -> (undeclared)  (capacity not declared -- assumed ok)
```

An undersized host is `Feasible() = FALSE` and never commits. A host with a
**`Provider`** is *scriptable* — it is feasible because it can be **provisioned to
meet the need**, the IaC move: don't just deploy to a host, bring one into
existence sized to the requirement. `Provision(req)` runs the provider CLI derived
from the resource spec, through the managed child:

```
proxmox: qm create --name vm --memory 2048 --cores 2 --scsi0 local:20
aws:     aws ec2 run-instances --instance-type t3.large
```

Proxmox takes the raw spec (`--memory` / `--cores` / disk); AWS maps memory to an
instance type. The `provision` plan step calls this, so a scriptable host is
created *as part of the rollout*, before its artifact is stored.

## 4. How they compose — toward full automation

The two dimensions meet in one run: the plan's **`provision` step** consults the
part's **requirement**, provisions the **scriptable host** to fit, then stores,
launches, and verifies — with the **feasibility** pre-flight refusing an
impossible placement before any of it starts, and **rollback** undoing a partial
failure. Nothing is decided twice: `Explain()` shows the exact plan and the
feasibility verdict; `Run()` executes precisely that, governed.

## 5. What it maps to

| CI / IaC idea | Softanza |
|---|---|
| job DAG (`needs:`), resource graph | `Steps()` + `After(part, dependsOn)` (topologically ordered) |
| gates (`if:`, readiness probes) | the `verify` step |
| apply-or-revert | transactional `Run()` (rollback on failure) |
| `resources.requests` / `runs-on` | `RequiresIn(part, spec)` |
| scheduler admission | `Feasibility()` / `Feasible()` |
| providers (AWS/GCP/Proxmox) | `site.Provider(name)` + `Provision(req)` |
| desired-state, plan / apply | `Explain()` (rehearse) / `Deploy(:Production)` (commit) |
| environment approvals | the governance crossing (an effectful actor) |

## 6. Verified

`deployment_narrated` (45/45) exercises all of it: the simple chain
(`store -> launch -> verify`); `After()` ordering a frontend behind its backend's
verify; a failing step rolling back the part that had already deployed; a fitting
host feasible, an undersized one blocked, a scriptable one feasible by
provisioning; and the proxmox/aws provision commands derived from the resource
spec.

---

*A deployment plan is a rehearsable, ordered, gated, reversible sequence; a host is
sized to what runs on it, and created if it must be. Both are named, inspectable,
and governed — so a complex rollout is as legible before it runs as a simple one.*
