# The Softanza Deployment Technology
### From definition to launch: storing and running a solution on config-described target sites

> Status: built. Components: `stzDeploymentSite`, `stzDeployment`,
> `stzBuilderBrain.Deploy(:Production)`. Guard: `deployment_narrated` (45/45).
> Tutorial: [stz-deploying-to-target-sites-narration.md](../narrations/stz-deploying-to-target-sites-narration.md).
> The plan of steps + provisioning are in [SOFTANZA_DEPLOYMENT_PLAN.md](SOFTANZA_DEPLOYMENT_PLAN.md).
> Sits atop the [emulation technology](SOFTANZA_EMULATION.md) and the governance
> crossing; part of the [Softanza delivery plane](SOFTANZA_DELIVERY_PLANE.md).

---

## 1. The problem: after "it works", the target is still a maze

Emulation answers *does the solution work?* — every part running its real engine
in the browser ([SOFTANZA_EMULATION.md](SOFTANZA_EMULATION.md)). But a working
solution still has to *land somewhere and run*, and that last mile is its own
friction:

- **Tool sprawl.** The phone build goes to an app store; the backend to a Linux
  server over SSH; the firmware flashes to a device; a container to a registry.
  Each is a different tool with a different config, none aware of the others.
- **Access is scattered and secret.** Reaching a target means knowing its
  endpoint, its protocol, *and* a credential — spread across shell history, CI
  YAML, and a secrets manager, never in one inspectable place.
- **"Who may deploy?" is a policy, not a property.** In most stacks nothing stops
  the wrong actor (a script, an agent) from pushing to production; it's a
  convention, enforced by hope.

Softanza's position: the target should be **one config away**, and deploying to
it should be **one governed act** — expressible right where the solution was
defined and emulated.

## 2. The thesis: a target is a config-described *site*, and the config is the link

A **deployment site** (`stzDeploymentSite`) is a named *destination* — a "target
repo" in the loosest sense: a server, a git repo, a container registry, a device,
an object store, a local folder. It is described entirely by its **access
config**:

- **connection** — `endpoint`, `protocol`, and an **auth reference** (a pointer to
  a credential, e.g. `env/DEPLOY_KEY` — *never* an inline secret);
- **storage** — where the artifact lands;
- **control** — how to launch it and how to read its status.

That config is the **link**. It is inspectable data (`Config()`), human-readable
(`ConfigText()`), and persistable (`ConfigJson()` / `SaveConfigTo()`) — so a site,
once described, is reachable and controllable *from inside the programming
environment*, and the description can be versioned and shared like any other
source.

```
site 'prod-api' [server]
  connection: ssh -> deploy@api.restolean.app:/srv/restolean   auth: env/DEPLOY_KEY
  storage:    /srv/restolean/api
  launch:     systemctl restart restolean-api
```

This is distinct from `stzSystemProfile`, which says what a target *can do* (its
capabilities). A site says how to *reach and drive* it. A target has both faces:
what it's allowed to do, and how you get to it.

**Secrets never inline.** A site carries an *auth reference*, not a key. The
config can be committed to source control without leaking anything; the actual
credential is resolved (from the environment, a keychain, a secrets manager) only
at the moment of transfer.

## 3. The deployment act: bind, store, launch, report

A **deployment** (`stzDeployment`) sends each part of a solution to a site and
performs the act:

```ring
oDep = new stzDeployment(oBrain)
oDep.To(:phone, oAppStore).To(:api, oProdApi).To(:node, oFleet)
? oDep.Explain()      # rehearse: which part goes where, and how
oDep.Store()          # place each part's artifacts on its site
oDep.Launch()         # start them
? @@( oDep.Status() ) # report back
```

`Explain()` rehearses the whole thing before anything moves — every part, its
bound site, the protocol it's reached by, and where it stores:

```
Deployment of 'restolean' -- from definition to launch (rehearsal)
  Part 'phone' [superapp] -> android
     site:   app-store [localrepo]     reach: file -> (local)     store: .../phone
  Part 'api' [backend] -> linuxserver
     site:   prod-api [localrepo]      ...
  Part 'node' [firmware] -> esp32
     site:   fleet [localrepo]         ...
  Store() places each part's artifacts on its site; Launch() starts them;
  Status() reports back -- governed: only an effectful actor commits.
```

The stored artifact carries the part's **engine subset** (from the plan's
`[stz.wasm]` capabilities) — so deployment stays tied to the differential edge:
the phone's package records that it ships `aggregation + solver`, nothing more.

Backends dispatch by `Kind`: `:LocalRepo` stores / launches / reports **for real**
today (a local folder standing in for a real repo); `:Server` / `:GitRepo` /
`:Registry` / `:Device` declare their config now, and their live transfer is the
next slice — *the config model does not change* when a real backend lands.

## 4. Governed: expression is free, admission is governed

Deploying is the ultimate reality-touching act, so it crosses the **same
governance gate** as the rest of the System Foundation. A deployment carries an
**actor**, and `MayCommit()` requires that actor to hold the *effectful*
capability:

```ring
oDep.AsActor(HumanActor("ops"))     # MAY commit
oDep.AsActor(LLMActor("assistant")) # may rehearse, commits NOTHING
```

An LLM (or any inference-only actor) can bind sites, `Explain()` the plan, and
call `Store()` / `Launch()` — but nothing lands: the calls return
*"rehearsed (not committed)"* and the disk is untouched. A human or ops actor
commits for real. This is "agents that cannot hurt you" as an enforced property,
not a promise — the same lattice that governs every other reality-touching plan.

## 5. One verb, two phases — `Deploy(:Emulated)` rehearses, `Deploy(:Production)` commits

Deployment is modeled Scope-Orientedly: the *phase* is the scope, and one verb on
the brain serves both. You bind sites on the brain, then choose the phase:

```ring
oBrain.DeployTo(:phone, oAppStore).DeployTo(:api, oProdApi).DeployTo(:node, oFleet)
oBrain.AsActor(HumanActor("ops"))

oBrain.Deploy(:Emulated)     # rehearse in the browser (the emulator)
oBrain.Deploy(:Production)   # commit to the sites (store + launch), governed
```

`Deploy(:Production)` assembles a `stzDeployment` from the brain's bindings and
actor and — **only if the actor may commit** — stores and launches it; otherwise
it returns the deployment as a rehearsal. So it is **safe by default**: a bare
`Deploy(:Production)` with no actor set touches nothing. Emulation is where you
find out it works; production is where the *same* parts, at the *same* scope, go
live:

```
  phone  ->  app-store  :  launched
  api    ->  prod-api   :  launched
  node   ->  fleet      :  launched
```

## 6. Architecture

```
  stzBuilderBrain          define the solution + WHERE each part deploys
      | DeployTo(part, site), AsActor(actor)
      | .Deploy(:Production)
      v
  stzDeployment            bind each part to its site; Explain() rehearses;
      |                    Store()/Launch()/Status() perform -- GOVERNED
      |                    (MayCommit() = actor.Can("effectful"))
      v
  stzDeploymentSite        a config-described destination (the "target repo"):
                           connection (endpoint/protocol/auth-ref) + storage +
                           control. Config()/ConfigJson()/SaveConfigTo() = the link.
                           Backend by Kind: :LocalRepo real; :Server/:GitRepo/
                           :Registry/:Device declared (live transfer = next slice).
```

## 7. Status

**All built.** On top of the site config model, governance gate, and dual-phase
`Deploy` described above, the deployment now has:

- **Live backends** — `:LocalRepo` and `:GitRepo` proven end to end (real `git`
  push, byte-for-byte); `:Server` (scp/ssh), `:Registry` (docker), `:Device`
  (flash) generate correct commands run through the managed child, one reachable
  host/account away from literal.
- **The plan of steps** — an ordered, gated, transactional DAG
  (`provision → store → launch → verify`, `After()` dependencies, verify gate,
  rollback) — and **resource feasibility + provisioning** (requirements, host
  capacity, a scriptable host provisioned to fit). Both are documented in
  [SOFTANZA_DEPLOYMENT_PLAN.md](SOFTANZA_DEPLOYMENT_PLAN.md).
- **Real artifact shipping** — a part's actual build outputs (`stz_<part>.wasm`,
  the app bundle, the native binary), a whole **bundle directory**, or each
  frontend's **per-part slice** (its app + engine + bridge), shipped byte-for-byte;
  the very emulator bundle you debugged wires straight into a production attach.

Guard `deployment_narrated` 45/45. The two layers that touch the outside world for
real — the git backend and the compiled wasm — are proven end to end.

**Remaining (infrastructure-gated):** live `ssh`/`aws` verification against a real
host or account; more providers.

---

*Deployment in Softanza is one continuous program with the rest: define the
solution, emulate it for real, describe its targets as configs, and — with an
actor that may commit — store and launch it. The maze becomes a config, and the
last mile becomes one governed act.*
