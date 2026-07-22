# From Dev to Deploy Without Leaving Your Editor
### How Softanza models the whole system journey as one program

Building a product that runs on more than one machine is, in most stacks, an
exercise in *tool management*. A backend that deploys to a Linux server, a phone
app that ships to Android, firmware that flashes to a microcontroller — each is
a different world, reached through a different tool: an IDE, a Dockerfile, a CI
YAML, a cross-compiler, a flash script, a cloud IAM policy, a secrets manager.
None of them knows about the others. Each holds one slice of the truth. And the
gaps between them are exactly where "it worked on my machine" is born.

Underneath the tool sprawl is a subtler tax: a set of **invisible frames** the
programmer must carry in their head and re-supply on every line —

- *Which system does this code run on?* (my laptop now, the device later)
- *What is that system allowed to do?* (an MCU has no processes; a phone is sandboxed)
- *Will this even run there?* (I have no GPIO on my laptop)
- *How do I get it there?* (build, cross-compile, flash, provision)

Softanza's System Foundation makes each of those frames a **named, checkable
thing** — and models the whole dev-to-deploy problem as a single object graph in
one vocabulary. The result is that the journey from your editor to a running
device can be *one continuous program*, not seven disconnected tools. This
narration walks that program end to end. Every code block below is real, and
every output block is its actual output.

---

## One developer, one product

Meet a developer on a Windows laptop building a **smart greenhouse**: a Linux
backend, an Android companion app, and an ESP32 sensor node that reads soil
moisture and drives a pump. Here is their whole dev-to-deploy session.

### 1. Who am I developing on?

No guessing, no ambient "current machine." The development system is an object
you instantiate, read live from the engine:

```ring
o1 = new stzDevSystem()

? o1.OSName() + " / " + o1.Architecture() + " / " + o1.BitSize() + "-bit"
#--> windows / x64 / 64-bit

? @@( o1.Capabilities() )
#--> [ "filesystem", "process", "network", "environment", "dynamic_load", "threads", "clock" ]

? o1.Lacks(:gpio)
#--> 1
```

That last line matters more than it looks: the machine's *capabilities* are
first-class data. The object knows the laptop has no GPIO — and it will use that
fact in a moment to help, not to block. (`CurrentSystem()` — a `new
stzCurrentSystem()` — is its runtime-scope twin: on a deployed device it reads
*that* device.)

### 2. Model the whole product once

The deployment architecture is **declared data**, in four lines, in one place —
not scattered across a Dockerfile, a compose file, and a CI pipeline:

```ring
oProduct = new stzPlatformProfile("smart-greenhouse")
oProduct.DevelopedOn(:Windows)
oProduct.AddServer(:backend, :LinuxServer)
oProduct.AddSuperApp(:phone, :Android)
oProduct.AddApp(:sensor, :ESP32)
```
```
Platform: smart-greenhouse
  developed on: windows
  server 'backend' -> linux
  superapp 'phone' -> android
  app 'sensor' -> espidf
```

Each part has a **kind** (server / superapp / app) and a **target system**. The
profile only *describes* the solution; nothing is built or deployed yet.

### 3. Write feature code in a named scope

This is where the tax disappears. Feature code for a part is authored against
that part's *target*, and checked on the laptop, as it is typed:

```ring
? oProduct.ReadPinIn(:sensor, 34)      # read the moisture pin
? oProduct.WritePinIn(:sensor, 26, 1)  # drive the pump
oProduct.SpawnIn(:sensor, "worker")    # ... and try to spawn a process
```
```
ReadPin(34)    -> rehearsed   (ESP32 allows gpio; rehearsed -- my laptop has none)
WritePin(26,1) -> rehearsed
Spawn('worker') -> REFUSED here, on my laptop, at write time
                   (an MCU has no processes -- I learn it NOW, not on the bench)
backend Spawn('cron') -> native   (Linux + my laptop both have processes)
```

Read those four results as a programmer, not a spec:

- **`Spawn` on the sensor was refused — on the laptop, at write time.** In a
  conventional flow you learn that an MCU has no processes *after* cross-compiling
  and flashing, staring at a dead board, or from a field crash. Here the whole
  class of "the target won't allow that" errors moved from production to your
  editor. This is *shift-left* applied to the deployment target itself.

- **`ReadPin` came back `rehearsed`, not refused.** The ESP32 *does* have GPIO;
  the laptop doesn't. Rather than fail, the scope **rehearses** the operation —
  so you can write and reason about firmware for hardware you do not physically
  have. The absent world is made present.

- **The same `Spawn` is `native` on the backend.** The scope, not the operation,
  decides. One verb, three verdicts, each correct for its target.

### 4. A risky system change? Rehearse it first

System operations that touch reality — reorganising files, changing the
environment, spawning children — go through a **twin**: an in-memory rehearsal
that holds no reference to reality. You try things, read a plain-language plan,
and *reality changes only when you commit it*:

```ring
oVfs = new stzVirtualFileSystem()
oVfs.CreateFolder("config")
oVfs.CreateFile("config/greenhouse.ini", "pump_threshold=40")
oVfs.MoveFile("old_settings.txt", "config/legacy.ini")
oPlan = oVfs.GenerateUpdatePlan()
? oPlan.Narration()
```
```
Update plan (3 of 3 operations to commit):
  * 1. create folder 'config'
  * 2. create file 'config/greenhouse.ini' (17 bytes)
  * 3. move 'old_settings.txt' -> 'config/legacy.ini'

reality is untouched until I choose to commit this plan.
```

System programming stops being "one wrong command and it's gone."

### 5. Build, then Deploy

A real **`stzPlatform`** owns the profile and drives its lifecycle. *We do not
deploy a profile* — we deploy a platform and its parts, and building precedes
deploying as two honest, ordered steps:

```ring
oPlatform = StzPlatformQ("smart-greenhouse")
oPlatform.SetProfile(oProduct)
oPlatform.Build()
oPlatform.Deploy()
```
```
Build()  -> built 3 parts
Deploy() -> lowered + delivered each part to its target
```

### 6. The firmware — written on a laptop with no GPIO

At deploy, the **lowering bridge** turns each part's rehearsed operations into a
real target artifact. The GPIO code the developer wrote on a Windows laptop
becomes actual firmware source:

```ring
? oPlatform.ArtifactFor(:sensor)
```
```
// firmware generated by the Softanza lowering bridge
// target: espidf
void setup() {}
void loop() {
  digitalRead(34);
  digitalWrite(26, 1);
}
```

`ReadPin(34)` lowered to `digitalRead(34)`; `WritePin(26, 1)` to
`digitalWrite(26, 1)`. The developer validated firmware logic without ever
holding the board. The board is now the *last inch*, not the prerequisite for
any progress.

### 7. The backend, cross-compiled for real — from the same laptop

The lowering bridge writes the *source*; **`stzBuilder`** turns it into a real
binary for the target. Softanza's engine is built with Zig, and Zig is a complete
multi-platform cross-compiler — so the Linux backend builds *from the Windows
laptop* with no separate toolchain. And the build target is not re-specified: it
**is** the part's deployment system, the same object that governed what the code
may do:

```ring
oBuild = new stzBuilder("backend")
oBuild.AddSourceQ("backend.c")
oBuild.SetTargetQ( oProduct.App(:backend).DeploymentSystem() )   # a system IS a build target
oBuild.ReleaseFast()
oBuild.Build()

? oBuild.Target()
#--> x86_64-linux-gnu

? oBuild.Succeeded()
#--> 1
```

The output is a genuine Linux ELF executable, produced on Windows — the same
laptop with no GPIO, no Linux, and now no Linux toolchain either. The deployment
system that decided *what the code may do* is the very object that decides *what
it compiles to*. One profile carries the whole journey, from "which machine?" to
a shippable binary.

### 8. Hand it to an AI copilot

The very same capability model that decided "can the ESP32 spawn?" decides "can
this actor deploy?" Deployment is an *effectful* crossing, so an actor whose
effect-capability set is empty — an LLM — may **propose** it but cannot
**perform** it:

```ring
oGuarded.DeployAs(LLMActor("copilot"))   # raises
oGuarded.DeployAs(HumanActor("me"))      # proceeds
```
```
the copilot may PROPOSE the deploy -- but CANNOT perform it (no effect capability)
I approve; the human deploys. Expression is free; admission is governed.
```

You wrote no bespoke permission plumbing. Safety was a property of the model you
were already using.

---

## What changed, frame by frame

| The invisible frame | Conventionally you… | In Softanza you… |
|---|---|---|
| which system the code runs on | hold it in your head; hope prod ≈ dev | name the scope; `CurrentSystem()` resolves honestly |
| what the target permits | find out on the bench / in a crash log | it is **refused at write time on your laptop** |
| firmware for hardware you lack | need the board to test anything | rehearse → lower; the board is the last inch |
| a dangerous system op | back up, cross fingers, run it | rehearse in a twin, read the plan, commit |
| the deployment architecture | scattered across Dockerfiles / CI / manifests | one declared profile, four lines |
| shipping to the target | a separate toolchain + flash script | `Build()` then `Deploy()`, the same object |
| letting an agent touch it | write custom permission plumbing | the capability gate; LLM proposes, human commits |

---

## The deepest simplification: the seam collapses

"It worked in dev, it broke in prod" is a law of nature in conventional stacks
for one reason: **dev and deploy are two different worlds joined by a fragile
hand-off** — different tools, different config, different invisible assumptions,
discovered to disagree only at the boundary.

Softanza makes deploy a *first-class part of the dev-time model*. You write,
check, build, and deploy against the **same** profiles, with the target's real
constraints enforced on your machine *before the hand-off even exists*. The cliff
between the two worlds becomes a **named scope boundary you can see and check.**
That is the whole trick, and it is why the session above reads like one
continuous thought rather than a relay race between seven tools.

There is a unifying reason it holds together: **one vocabulary runs through the
entire pipeline.** The capability lattice — `effectful` / `sensing` / `compute`
/ `inference` — is the same word used for a system's capabilities, a deployment
scope's verdicts, an actor's authority, and the deploy governance gate. The
developer above learned four nouns — a capability, a scope, an actor, a plan —
*once*, and they carried from "what machine am I on?" to "here is the firmware"
to "the AI can't deploy it." The mental model never fragmented.

---

## Honest about the edges

A good tool is precise about what is real and what is modelled:

- The **flash / upload of the artifact to the physical device** is genuinely
  external — it needs the hardware. The model generates the firmware; the last
  inch is real, and stays honest about it.
- The **cross-compile is real**: `stzBuilder` drives Zig, a genuine multi-platform
  C/C++/Zig compiler — the Linux (and wasm) binaries above are verified by their
  ELF/wasm magic bytes, built from Windows. What stays *modelled* is the ESP32
  firmware **source** (`digitalRead` is a faithful Arduino stand-in); a real MCU
  build plugs an ESP-IDF / arduino-cli toolchain *behind the same builder
  interface*. The seam is unified; that one target still awaits its real tool.
- This does not replace every mature deploy tool. It unifies the **seams** those
  tools leave exposed — which is where the cognitive tax actually lives.

The claim that survives running it: Softanza does not make deployment more
*powerful* so much as it makes the dev-to-deploy problem **small enough to hold
in one head** — because it is one model, one vocabulary, checked early, on your
own machine.

---

### See also
- `../design/SOFTANZA_SYSTEM_FOUNDATION.md` — the full design: engine-true facts,
  the three scopes, the twin, the governance crossing, and the lowering bridge.
- `../design/SCOPE_ORIENTED_PROGRAMMING.md` — the paradigm underneath: name the
  operative scope at the call site and let the library reason with it (regex was
  the first governed field; system programming is the second).
- `stz-lowlevel-system-programming.md` — the low-level vision (safe memory,
  named cross-platform operations) this foundation sits on.
