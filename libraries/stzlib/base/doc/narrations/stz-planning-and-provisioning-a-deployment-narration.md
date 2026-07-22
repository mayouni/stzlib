# Planning and Provisioning a Deployment
### From a one-step rollout to an ordered, gated, self-provisioning one — and back if it fails

Deploying the [target sites](stz-deploying-to-target-sites-narration.md) taught the
verbs: store, launch, report, all governed. But real rollouts are rarely one step.
The backend must come up *before* the frontend that calls it. A health check must
pass before you proceed. A half-finished deployment must undo itself. And every
target must actually have the memory, compute, and storage the part needs — or be
created to have it.

That is two ideas the CI and infrastructure world has long modelled: the
deployment is a **plan of ordered steps**, and each host is **sized to what runs on
it**. Softanza models both, on top of the rehearse-then-commit machinery it already
had. This narration walks them. Every code block is real, and every output block is
its actual output.

---

## A deployment is a plan of steps

Take a small shop: a backend `api` and a browser `web` frontend. Bind each to a
site, and — before anything runs — ask the deployment to `Explain()` itself:

```ring
oB = new stzBuilderBrain("shop")
oB.WithBackend(:api, :LinuxServer)
oB.WithSuperApp(:web, :Browser)
oB.NeedsIn(:api, [ :PivotTable ])
oB.NeedsIn(:web, [ :Collection, :ConstraintSolver ])
oB.RequiresIn(:api, StzResourcesQ().Memory(2048).Compute(2).Storage(20))

oApi = new stzDeploymentSite("prod-api")
oApi.Kind(:Server).Provider(:proxmox)

oWeb = new stzDeploymentSite("cdn")
oWeb.Kind(:GitRepo).Endpoint("git@cdn:web.git")

oDep = new stzDeployment(oB)
oDep.AsActor(HumanActor("ops"))
oDep.To(:api, oApi)
oDep.To(:web, oWeb)
oDep.After(:web, :api)     # the frontend deploys AFTER the backend

? oDep.Explain()
```

```
  Host feasibility (required -> capacity):
     [ok  ] prod-api: 2048MB / 2 vCPU / 20GB -> (provision)  (provision on proxmox)
     [ok  ] cdn: 0MB / 0 vCPU / 0GB -> (undeclared)  (capacity not declared -- assumed ok)

  Plan (7 steps, in order; Run() executes them, governed):
     1. provision api -> prod-api
     2. store     api -> prod-api   (after provision:api)
     3. launch    api -> prod-api   (after store:api)
     4. verify    api -> prod-api   (after launch:api)
     5. store     web -> cdn        (after verify:api)
     6. launch    web -> cdn        (after store:web)
     7. verify    web -> cdn        (after launch:web)

  A verify gate must pass to proceed; a failure rolls back the completed steps.
  Governed: only an effectful actor commits.
```

Read the plan. A **simple** deployment is just the default chain per part —
`store → launch → verify`. This one is **complex**: `After(:web, :api)` made the
frontend's `store` wait for the backend's `verify` (step 5 depends on step 4), and
because `prod-api` is a *scriptable* host, a `provision` step leads the whole thing
(step 1). The steps are topologically sorted, so every dependency precedes its
dependants — a DAG, laid out before a byte moves.

Three properties are promised in that last block, and `Run()` delivers them:
**order** (the `after` edges), a **gate** (verify must pass), and **rollback** (a
failure undoes what completed).

## Sizing the host — feasibility

Notice the *feasibility* section above. A part **requires** resources; a host
**provides** them; feasibility is just "does it fit?". Declare a host's capacity and
ask:

```ring
oB.RequiresIn(:api, StzResourcesQ().Memory(2048).Compute(2).Storage(20))

oBig = new stzDeploymentSite("big")
oBig.Kind(:Server).Capacity(StzResourcesQ().Memory(4096).Compute(4).Storage(100))
d1 = new stzDeployment(oB)
d1.To(:api, oBig)
? "big host   -> Feasible=" + d1.Feasible()

oSmall = new stzDeploymentSite("small")
oSmall.Kind(:Server).Capacity(StzResourcesQ().Memory(1024).Compute(1).Storage(10))
d2 = new stzDeployment(oB)
d2.To(:api, oSmall)
? "small host -> Feasible=" + d2.Feasible()
```

```
  big host   -> Feasible=1  (fits)
  small host -> Feasible=0  (SHORTFALL -- host too small)
```

The undersized host is **not feasible** — a pre-flight that refuses an impossible
placement before any commit, the same admission a Kubernetes scheduler performs.

## When the host isn't there yet — provision it

`prod-api` had no declared capacity, but it *did* have a `Provider(:proxmox)`. That
makes it **scriptable**: feasible not because it fits, but because it can be
**created to fit**. `Provision(req)` builds the provider command straight from the
resource spec:

```ring
oPx = new stzDeploymentSite("vm")
oPx.Provider(:proxmox)
? oPx.ProvisionCommandFor(StzResourcesQ().Memory(2048).Compute(2).Storage(20))

oAws = new stzDeploymentSite("vm2")
oAws.Provider(:aws)
? oAws.ProvisionCommandFor(StzResourcesQ().Memory(8192).Compute(4).Storage(50))
```

```
qm create --name vm --memory 2048 --cores 2 --scsi0 local:20
aws ec2 run-instances --instance-type t3.large
```

Proxmox takes the raw spec; AWS maps the memory to an instance type. The `provision`
step in the plan runs exactly this — so a scriptable host comes *into existence*,
sized to the requirement, as the first step of the rollout. This is the
infrastructure-as-code move: don't just deploy to a host, bring one about.

## Run it — and roll back if a step fails

Now the promise that matters most. Deploy a `web` frontend and an `api` backend,
order the backend *after* the frontend, and let the backend's store fail (its remote
isn't reachable). `Run()` executes the plan and reports every step:

```ring
oGood = new stzDeploymentSite("cdn")
oGood.Kind(:LocalRepo).StoreAt("/srv/cdn")
oBad = new stzDeploymentSite("prod-api")
oBad.Kind(:Server)                       # remote store fails: no host reachable

oDep = new stzDeployment(oB)
oDep.AsActor(HumanActor("ops"))
oDep.To(:web, oGood)
oDep.To(:api, oBad)
oDep.After(:api, :web)                   # web fully deploys, THEN api

aRun = oDep.Run()
? "committed: " + aRun[1]
for i = 1 to len(aRun[2])
    ? "  " + aRun[2][i][1] + "  ->  " + aRun[2][i][2]
next
? "web site status after: " + oGood.Status()
```

```
  committed: 0
  store:web   ->  done
  launch:web  ->  done
  verify:web  ->  done
  store:api   ->  FAILED
  launch:api  ->  skipped
  verify:api  ->  skipped
  web site status after: rolledback
```

The web frontend stored, launched, and passed its gate. Then the api's store
**FAILED**, so the remaining steps were **skipped** and the deployment **did not
commit** — and, crucially, the web frontend that had *already* deployed was
**rolled back**. The rollout is transactional: all of it lands, or none of it does.
Had a benign actor run it, every step would have merely rehearsed and nothing would
have moved at all.

## Define, size, plan, run

That is the whole shape. You said what each part needs — its capabilities *and* its
resources. The brain laid out an ordered plan and told you, before committing,
whether each host had room or could be provisioned to have it. And `Run()` executed
that exact plan: provisioning where needed, honoring the dependencies, gating on the
health checks, and — on failure — undoing itself, governed at every commit. A
complex rollout, as legible and safe as a simple one.
