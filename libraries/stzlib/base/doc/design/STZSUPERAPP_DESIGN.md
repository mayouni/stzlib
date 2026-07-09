# stzSuperApp - a living constellation of worlds

> Forward design / thinking piece. Builds on `stzApp` ("an application is a living world of
> meaning", see STZAPP_DESIGN.md). Where stzApp models ONE world, stzSuperApp models MANY
> worlds federated into one governed solution -- deployable and developable across web,
> desktop, mobile, and beyond. Written in the Softanza spirit: question the conventional
> model, then rebuild around meaning.

---

## 0. The construct

The industry's "super-app" is a *host* that embeds a *runtime* to run sandboxed *mini-apps*
sharing native services and a store (FinClip, WeChat, and kin). That is a description of
the *plumbing*, not the *essence*. Softanza refuses it and asks what a super-app **is**:

> **A super-app is a living constellation of worlds.**
>
> A governed graph whose nodes are **stzApps** (living worlds), sharing a **common ground**
> (identity, data, services), bound by **relations** (navigation, flows, calls), each
> **reaching** its own platform and persona -- composed and governed as one solution.

Softanza is **graph-native and recursive**: a world is a graph; a super-app is a graph whose
nodes are worlds -- a graph of graphs. And a world *inside* a constellation can itself be a
constellation. So the same construct scales from a two-screen tool to a national platform.

`stzSuperApp` is a Base-layer Softanza construct; like everything, it is mostly composition
-- it federates `stzApp` worlds over `stzGraph`, governed by norms, reached via the
platform generator.

---

## 1. Why (the conventional need, reframed)

Real solutions are rarely one app. A bank has a field tool, an admin console, a customer
portal, a partner API -- each for a different persona, on a different platform, yet sharing
customers, accounts, rules, and identity. The conventional answers fragment this into
separate codebases glued by integrations, or force it into one "host + mini-apps" runtime
with a proprietary sandbox and store.

Softanza reframes each pain:

| Conventional super-app | Softanza reframing |
|---|---|
| **host app** (privileged container) | the **Commons** -- the shared ground worlds stand on |
| **mini-app** (lite, second-class, sandboxed) | a **world** (`stzApp`) -- first-class; there is no "mini" vs "full", only apps composed into a constellation |
| **runtime + sandbox** (technical isolation) | each world's **Body + Governance boundary** -- isolation is *declared meaning* (what's sovereign vs shared), not a black box |
| **native bridge** (host exposes camera/pay) | the **`stz.platform`** capability seam + the Softanza engine's own native capabilities |
| **mini-app store** (discovery) | a **registry graph** -- discovery is traversal of the constellation |
| **manual review / permissions** | **norms** (PI-first, agentic-safe) -- admission and rights are declared and enforced |
| **proprietary 3MB runtime** | the **one Softanza engine** (no third-party dependency) -- self-contained, deploy-anywhere |

The load-bearing shift: **worlds, not mini-apps; a governed graph, not a host container.**

---

## 2. The aspects (mirroring stzApp, one dimension up)

Everything is a world; a super-app is a graph of worlds. Three aspects **constitute** it, one
**ambient** governs it, two **emergents** meet it -- the same shape as stzApp (being / becoming
/ body, then met from without).

**CONSTITUTIVE -- what the constellation is made of**
- **CONSTELLATION** (being) -- the member **worlds** it federates. Each `Hosts(:World)` is a
  node = a whole `stzApp`. (stzApp's Domain was things; here the things are worlds.)
- **BONDS** (becoming) -- how worlds relate and move: **navigation** (A opens B), **flows**
  (data moves between worlds), **uses** (a world calls a commons service), **events** (a world
  reacts to another). Edges in the super-graph. (stzApp's Life, between worlds.)
- **COMMONS** (body / shared ground) -- the shared **identity, data, ledger, services** the
  worlds stand on and endure by. The Commons is itself a **world -- "world zero"** (see 2.1) --
  so a world may draw on the shared Commons or keep a **sovereign** Body; shared-vs-sovereign is declared.

**AMBIENT -- what governs the whole**
- **GOVERNANCE** (the constitution of the constellation) -- not a part you can strip but the
  ambient over all parts: **admission** (which worlds join, with what capabilities), **rights**
  (norms on who may see/do what), **data-sharing** and **cross-world call** policy. Declared,
  truth-bounded, PI-first -- the norm-thread woven through Constellation, Bonds, and Commons.
  (This is also how isolation is expressed -- see 2.2.)

**EMERGENT -- how the constellation is met from without**
- **REACH** (appears) -- each world projects to its surface(s)/persona; the constellation spans
  web / desktop / mobile / IoT, hosted by a per-platform **shell**.
- **PRESENCE** (seen) -- `Explain()` narrates the whole: worlds, commons, bonds, rights. No
  black box; governance is visible.

### 2.1 The Commons is a world ("world zero")
For full uniformity and recursion, the Commons is not a special *kind* of node -- it is a
**world** like any other, distinguished only by **role**: it holds the shared Domain (identity,
ledger) and Provides services, and every other world Bonds to it. So `Shares(:Identity)` /
`Provides(:Payments)` at super-level simply constitute world-zero. In a nested super-app, a
sub-constellation's commons is just *its* world-zero -- the same construct all the way down.

### 2.2 Isolation = declared boundaries, not an opaque sandbox
A world's boundary is its **sovereign Body** (its own state -- no world can reach into another's)
plus the **norm gate on its Bonds** (the only doors between worlds are declared Bonds and Commons
access, each governed). A world granted nothing is fully isolated. This is Softanza's answer to
the mini-app sandbox: isolation as *declared, inspectable meaning* rather than a black-box VM. For
genuinely untrusted (e.g. third-party) worlds, the platform shell may add a runtime sandbox as an
*implementation* of that declared boundary -- but the meaning stays: sovereign-Body + norm-gated-Bonds.

> The test: strip Reach/Presence and you still have a *governed constellation of worlds sharing a
> commons*. Strip the Constellation or the Commons and there is no super-app -- just separate apps.

---

## 3. Recursive & composable (this is the earlier thesis, generalized)

Our common-ground work already described *"one solution, many platform-specialised shells
over a shared core, governed globally -- admin console as desktop, customer portal as web,
sales rep as mobile, each owning part."* **That is a stzSuperApp.** Now it is a first-class
construct:

```
          SUPER-APP "Sonibank"  (a constellation, governed as one)
   COMMONS: identity - ledger(accounts,clients) - payments - messaging
        |                    |                        |
   AdminConsole          Portal                    VisitApp
   world / desktop       world / web               world / mobile
   :admin governs        :customer self-serve      :sales, offline
        \____________ bonds: opens / flows / uses ____________/
```

Because a world can itself be a constellation, big solutions nest: a "Banking" super-app
hosts a "Lending" super-app that hosts individual worlds -- the same construct, all the way.

---

## 4. The idiom (near-natural, consistent with stzApp)

```ring
oSuper = new stzSuperApp("Sonibank")
oSuper {
    # COMMONS -- the shared ground
    Shares(:Identity)                              # one identity across worlds
    Shares(:Ledger)                                # a shared data commons (accounts, clients)
    Provides(:Payments)   Provides(:Messaging)     # commons services

    # CONSTELLATION -- the worlds it federates (each a stzApp)
    Hosts(:VisitApp)     { For(:sales)    On(:mobile)  Sovereign([:visits])  Offline }
    Hosts(:AdminConsole) { For(:admin)    On(:desktop) Governs([:referential, :audit]) }
    Hosts(:Portal)       { For(:customer) On(:web) }

    # BONDS -- how worlds relate and move
    Bond(:Portal,   :opens,     :VisitApp)         # navigation between worlds
    Bond(:VisitApp, :uses,      :Payments)         # a world uses a commons service
    Flow(:VisitApp, :reportsTo, :AdminConsole)     # cross-world data flow

    # GOVERNANCE -- norms over the whole
    Admits(:VisitApp)  With([ :camera, :offline ])         # capabilities granted
    Norm(:AccountsAreViewOnly)  AppliesTo(:all)            # a truth, federated

    # REACH -- the shell across platforms
    Reaches([ :web, :desktop, :mobile ])
}

oSuper.Explain()          # narrate the whole constellation (worlds, commons, bonds, rights)
oSuper.Generate(:all)     # host shells per platform + the worlds, deployable
```

Each `Hosts(:X)` references a `stzApp` world (defined in its own module/file). The super-app
is the graph of these plus their bonds, commons, and norms.

---

## 5. Deploy & develop (the "agile, easy to deploy" goal)

Same delight as the app generator, one level up:

- **Drop-in:** a `stzsuperapp/` folder declares the constellation; `make <target>` / `make
  all` generates, per platform, a **host shell** (web PWA / desktop Tauri / mobile Capacitor)
  embedding the one Softanza engine, plus each **world** as an independently loadable unit,
  plus the wired **commons**.
- **Independent worlds:** a world can be updated/added/retired without rebuilding the host
  (push a world; the registry graph discovers it) -- Softanza's answer to "mini-app updates"
  but governed by norms, not a store's rules.
- **Self-contained:** `[worlds] + [runtime] + [stz engine]` -- one dependency, portable
  everywhere (the Softanza promise, inherited).
- **Governed by construction:** admission, rights, data-sharing are declared; a world can't
  reach beyond its granted capabilities or a federated truth.
- **Agentic-ready:** worlds *strive* (goals/plans, PI-first); the constellation can be driven
  by agents that propose cross-world actions -- gated by governance.

---

## 6. What it composes (nothing new invented)

| Aspect | Softanza it builds on |
|---|---|
| worlds | `stzApp` (each Hosts is a world) |
| the constellation graph & bonds | `stzGraph` (a graph of worlds; bonds are edges) |
| commons / shared vs sovereign Body | `stzApp` Body + shared data model |
| governance / norms | truths + norms (the `IsTrue`/norm layer), PI-first |
| platform shells & reach | the `stz.platform` seam + the multi-target generator (web/desktop/mobile) |
| discovery / registry | graph traversal (`stzGraphQuery`) over the constellation |
| cross-world flows / events | `stzWorkflow` + Reaxis, between worlds |

---

## 7. Softanza differentiators (vs conventional super-apps)

1. **Worlds, not mini-apps** -- uniform, first-class; no lite/full split.
2. **Graph-native federation** -- a super-app is a graph of app-graphs; composition is graph
   composition; discovery is traversal.
3. **Declared shared-vs-sovereign** -- the commons and each world's private Body are explicit
   meaning, not an opaque sandbox.
4. **Governed by norms, PI-first, agentic-safe** -- not a store review + permission list.
5. **One engine, no proprietary runtime** -- self-contained, deploy-anywhere.
6. **Recursive** -- a world can be a constellation; solutions nest without new machinery.

---

## 8. Resolved decisions & prerequisite
- **Aspects** -- a constitutive triad **Constellation (being) / Bonds (becoming) / Commons
  (body)**, one **Governance** ambient (the constitution of the constellation), and two emergents
  **Reach / Presence** -- mirroring stzApp exactly (being/becoming/body, then met from without).
  Governance is the ambient, not a fifth parallel facet. (See 2.)
- **Isolation** -- **declared boundaries**: a world's sovereign Body (state no one else can reach)
  + norm-gated Bonds (the only doors, all governed). A runtime sandbox is only an *implementation*
  for untrusted worlds, never the definition. (See 2.2.)
- **Commons** -- **a world ("world zero")**: uniform and recursive, not a special kind of node.
  `Shares`/`Provides` constitute it. (See 2.1.)
- **Prerequisite** -- stzApp (Slice A green; B..E pending, see STZAPP_STATUS_AND_NEXT.md) is the
  foundation; grow stzSuperApp once worlds are solid.

---

*A super-app is a living constellation of worlds -- members, a commons, and their bonds,
governed as one and reached everywhere. Softanza gives the worlds and the graph that binds
them; what the constellation is for is yours.*
