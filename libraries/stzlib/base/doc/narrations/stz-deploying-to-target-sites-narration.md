# Deploying to the Target Sites
### How Softanza takes a working solution the last mile — to real sites, as one governed act

The [emulator](stz-emulating-the-whole-solution-narration.md) answered the hard
question: *does it work?* Every part ran its real engine in the browser, so you
know the solution is sound. But sound isn't shipped. The phone package still has
to reach an app store, the backend a server over SSH, the firmware a device — and
in most stacks that last mile is a scramble of tools, scattered credentials, and
an unspoken hope that only the right person pushes to production.

Softanza's position is that the target should be **one config away**, and
deploying to it should be **one governed act**, expressible right where you
defined and emulated the solution. This narration walks that final step. Every
code block is real, and every output block is its actual output.

---

## A target is a config — the link that makes it reachable

You don't "connect to" a deployment target in Softanza; you *describe* it. A
**site** is a named destination, captured entirely by its access config —
connection, storage, and control:

```ring
oProdApi = new stzDeploymentSite("prod-api")
oProdApi.SetKindQ(:Server)
oProdApi.SetEndpointQ("deploy@api.restolean.app:/srv/restolean")
oProdApi.SetProtocolQ(:ssh)
oProdApi.SetAuthRefQ("env/DEPLOY_KEY")
oProdApi.SetStoreAtQ("/srv/restolean/api")
oProdApi.SetLaunchWithQ("systemctl restart restolean-api")

? oProdApi.ConfigText()
```

```
site 'prod-api' [server]
  connection: ssh -> deploy@api.restolean.app:/srv/restolean   auth: env/DEPLOY_KEY
  storage:    /srv/restolean/api
  launch:     systemctl restart restolean-api
```

Everything needed to reach and drive that server is in one inspectable place. Note
`auth: env/DEPLOY_KEY` — a **reference**, not a key. The config carries a pointer
to the credential, never the secret itself, so you can commit and share it freely;
the real key is resolved only at the moment of transfer. `oProdApi.SaveConfigTo(...)`
writes it out as a file — the link, persisted and versionable like any source.

## Bind each part of the solution to its site

The delivery planner already holds the solution — the phone super-app, the backend, the ESP32
node. Deployment adds *where each part lands*:

```ring
oDelivery = new stzDelivery("restolean")
oDelivery.AddSuperApp(:phone, :Android)
oDelivery.AddBackend(:api, :LinuxServer)
oDelivery.AddFirmware(:node, :ESP32)
oDelivery.NeedsIn(:phone, [ :Unicode, :PivotTable, :ConstraintSolver, :Collection ])
oDelivery.NeedsIn(:api,   [ :PivotTable ])
oDelivery.NeedsIn(:node,  [ :GPIO, :Pattern ])

oDelivery.DeployTo(oAppStore, :phone)
oDelivery.DeployTo(oProdApi, :api)
oDelivery.DeployTo(oFleet, :node)
```

Each part now has a home. Nothing has moved yet — you have only *said where things
go*.

## Rehearse before you touch anything

`Deploy(:Production)` with no actor set returns a **rehearsal** — it commits
nothing, and `Explain()` shows exactly what *would* happen:

```ring
? oDelivery.Deploy(:Production).Explain()
```

```
Deployment of 'restolean' -- from definition to launch (rehearsal)
==============================================================================
  actor: (none) -- rehearse only

  Part 'phone' [superapp] -> android
     site:   app-store [localrepo]
     reach:  file -> (local)
     store:  .../phone

  Part 'api' [backend] -> linuxserver
     site:   prod-api [localrepo]
     reach:  file -> (local)
     store:  .../api

  Part 'node' [firmware] -> esp32
     site:   fleet [localrepo]
     reach:  file -> (local)
     store:  .../node

  Store() places each part's artifacts on its site; Launch() starts them;
  Status() reports back -- governed: only an effectful actor commits.
```

Every part, its site, the protocol it's reached by, and where it stores — laid out
before a byte moves. The artifact each part will store even records its engine
subset, so the differential edge you scoped in emulation travels with it.

## Who may commit — expression is free, admission is governed

That last line of the rehearsal is the crux: *only an effectful actor commits.*
Deploying touches reality, so it crosses the same governance gate as everything
else in Softanza. A deployment carries an **actor**, and only one that holds the
*effectful* capability may cross:

```ring
oDelivery.SetActor(LLMActor("assistant"))   # may rehearse -- commits NOTHING
oDelivery.SetActor(HumanActor("ops"))       # may commit
```

Hand the deployment to an LLM and it can bind, explain, even *call* `Store()` and
`Launch()` — and the disk stays untouched; the calls come back
*"rehearsed (not committed)"*. This isn't a policy you remember to apply; it's a
property the code enforces. An agent can plan your entire release and change
nothing.

## Commit — the same parts, now live

Give it an actor that may commit, and `Deploy(:Production)` stores and launches for
real:

```ring
oDelivery.SetActor(HumanActor("ops"))
oLive = oDelivery.Deploy(:Production)
aStatus = oLive.Status()
for i = 1 to len(aStatus)
    ? "  " + aStatus[i][1] + "  ->  " + aStatus[i][2] + "  :  " + aStatus[i][3]
next
```

```
  phone  ->  app-store  :  launched
  api    ->  prod-api   :  launched
  node   ->  fleet      :  launched
```

Each part's artifact landed on its site, each site was launched, and the status
came back to your editor. The parts you emulated are the parts that shipped — same
scope, same engine subsets, one continuous program.

## Define, emulate, deploy — without leaving your editor

That is the whole arc. You described the solution once. You emulated it and each
part ran its real engine. You described the targets as configs — the links that
make them reachable. And with an actor permitted to commit, you stored and
launched the solution onto those sites, governed the whole way. The maze became a
config; the last mile became one act; and "it worked in emulation" and "it's live
in production" are, once more, the same sentence.
