# The operating-system boundary on Windows -- a study with measurements

*RADAR-OPENSHELL-OSBOUNDARY-01, Windows half; FOUNDRY-OSBOUNDARY-01 (stzfoundry rung AF7). stzlib-security, 2026-11-14.*

## The question

A deployed agent is a haro.exe process started by stzNodeSupervisor. Every refusal it meets today is decided inside
its own process. stzfoundry asked for a boundary outside the process, described by a grant:

| | the node may | |
|---|---|---|
| (a) | write only its runs folder and its health file | |
| (b) | read only the installed pack, the library, the engine and its one signing key | |
| (c) | reach no network unless the pack declares an endpoint | |
| (d) | start no child process | |
| (e) | stay under a memory ceiling and a processor-time ceiling, and be ended past them | |
| (f) | see a refusal and write it into its run record | |

stzfoundry measured low integrity first (stzfoundry e4ee8b0, probes/af7_*): it confines writes and children, and not
reads, network, memory or processor time. This desk answered (2026-11-14 02:09) that an AppContainer would give (a),
(b) and (c), and a job object (d) and (e). This study measures that answer before anything is built.

## How it was measured

`engine/tools/osboundary_spike.zig`, one Zig file with no dependency outside Windows:

    zig build-exe osboundary_spike.zig -O ReleaseSafe -luserenv -ladvapi32 -lws2_32
    osboundary_spike.exe                                   three runs of its own child mode
    osboundary_spike.exe haro <haro.exe> <script> <engine dir> <library dir> <job MB>

The parent creates an AppContainer profile and grants the container's SID access rules on chosen folders. It then
opens a job object, starts the child suspended with `PROC_THREAD_ATTRIBUTE_SECURITY_CAPABILITIES`, assigns it to the
job and resumes it. The parent reads the job's notifications through a completion port, and deletes the profile at
the end. The child's output reaches the parent through an inherited file handle, so no folder needs granting for it.

- **Machine:** Windows 11 Pro 10.0.26200, a standard user account, nothing elevated.
- **Runtime:** haro.exe main (sha256 b79b9368f789f0b5), copied to `%TEMP%\stz_osb\haro`.
- **Engine:** the runtime part of C:\haro-engine (stzlib f939470a5), copied to `%TEMP%\stz_osb\engine`: the `.haro`
  bindings, `data` and `zig-out\bin`, 477 MB copied in 1.2 s.
- **Library:** the stzlib worktree at 7071af3eb (19,587 tracked files). It was granted in place for the run, and the
  grant was revoked after it; a check of three paths afterwards found 0 container rules left.

## What Windows enforced

The spike's child, inside the container. Run 1 has no capability. Run 2 adds the internetClient capability. Both run
in a job limited to one active process and 256 MB of job memory.

| check | run 1 | run 2 |
|---|---|---|
| R1 read a file in the granted folder | reached | reached |
| R2 read a stand-in key the user owns, outside the grant | **refused** (5, access denied) | **refused** (5) |
| R3 read a repository file under D:\GitHub | **refused** (5) | **refused** (5) |
| R4 read a file of the user's profile (.gitconfig) | **refused** (5) | **refused** (5) |
| R5 read C:\Windows\System32\drivers\etc\hosts | reached | reached |
| W1 write in the granted folder | reached | reached |
| W2 write beside the stand-in key | **refused** (5) | **refused** (5) |
| W3 write in the user's TEMP | **refused** (5) | **refused** (5) |
| N1 TCP connect to the parent on 127.0.0.1 | **refused** (10060, timed out after about 21 s) | **refused** (10060) |
| N2 TCP connect to 1.1.1.1:80 | **refused** (10013, at once) | reached |
| C1 start cmd.exe | **refused** (1816, quota) | **refused** (1816) |
| M1 commit and touch 64 MB | reached | reached |
| M2 commit and touch 512 MB | **refused** (1455, commit limit) | **refused** (1455) |

The job reported NEW_PROCESS, ACTIVE_PROCESS_LIMIT (the cmd.exe attempt), JOB_MEMORY_LIMIT (the 512 MB commit),
EXIT_PROCESS and ACTIVE_PROCESS_ZERO. Each run began with two NEW_PROCESS messages for one child; this study did not
look into why.

**Run 3, the processor-time ceiling:** a child that spins, in a job with a 500 ms processor-time ceiling. It was
ended after 2,099 ms of wall time, with exit code 0xC0000044 (quota exceeded) and the job message END_OF_JOB_TIME.
The ceiling is enforced late: about 1.6 s of processor time past a 500 ms ceiling on one spinning thread.

## haro.exe inside the boundary

The script loads stzBase, calls the engine, then tries a read and a write outside the grant and a write inside it.
The container was granted read and execute on haro.exe's folder, the engine copy, the library and the script's
folder. It was granted full access on one folder, which holds the runs output and the Haro image cache
(`HARO_CACHE`).

| | outside, the control | inside, cold | inside, warm |
|---|---|---|---|
| loads stzBase, StzLen through the engine = 5 | yes | yes | yes |
| reads the stand-in key outside the grant | reached | **refused**: R35 "Can't create/open the file" | **refused** |
| writes outside the grant | reached | **refused**: R35 | **refused** |
| writes inside the grant | reached | reached | reached |
| wall time | 42.8 s | 61.1 s | **2.0 s** |
| peak job memory | not measured | **2,304 MB** | **233 MB** |

At a 1,024 MB ceiling the cold run failed with "compile failed: OutOfMemory" (JOB_MEMORY_LIMIT). Compiling the
library image needs more than 1 GB, while running a compiled image needs 233 MB.

The image the control compiled outside was not used inside: a second 52 MB image was written beside it. Inside, the
second run reused that second image. **Corrected by rung B2:** an image is kept per cache folder and root file,
not per container. The control had used the user's default cache folder and the container run a granted one; with
one HARO_CACHE for both, a node warmed outside started inside in 0.19 s at 233 MB.

## Costs

| step | measured |
|---|---|
| create the AppContainer profile | 30 to 36 ms |
| grant or revoke a small folder (a few files) | 0.6 to 2.1 ms |
| grant read on the engine copy (186 files in zig-out\bin) | 40 to 68 ms; revoke 49 to 78 ms |
| grant read on the library tree, in place | **2.5 to 4.0 s**; revoke **1.3 to 4.0 s** |
| start the child suspended, assign it to the job, resume it | 7 to 67 ms (the first spawn of a run is the slow one) |

The library grant is the one cost a supervisor would feel. Windows writes the inherited rule into every file of the
tree, which is why a grant on the library belongs at install and never on each start.

## The permission to grant, measured

stzfoundry met "Access denied" setting an integrity label under D:\GitHub, and this desk's answer took that to mean a
container's access rule could not be written there either. Measured here, the user opens D:\GitHub\_wts\libraries\stzlib,
C:\haro-engine and %TEMP%\stz_osb for WRITE_DAC with error 0, and the in-place grant on the library succeeded. Writing
an access rule for a container needs WRITE_DAC, which the user holds. Setting an integrity label is a different
operation, and its refusal does not apply to this design. **The supervisor can grant the installed library and engine in place**, and it still
builds each node's own folder (runs, health file, key, image cache), because that folder belongs to the node.

## What this means for the spawn

Each part of the Foundry's grant has a mechanism that was measured working:

| grant field | mechanism | measured |
|---|---|---|
| (a) write paths | full access for the container on each path | W1 reached, W2 and W3 refused |
| (b) read paths | read and execute for the container on each path | R1 reached, R2 to R4 refused; haro.exe ran with four folders granted |
| (c) network | the internetClient capability, only when the pack declares an endpoint | N2 refused without it, reached with it |
| (d) children | job, active-process limit 1 | C1 refused, ACTIVE_PROCESS_LIMIT reported |
| (e) memory | job memory limit | M2 refused, JOB_MEMORY_LIMIT reported |
| (e) processor time | job processor-time limit | ended with END_OF_JOB_TIME, about 1.6 s late |
| (f) the refusal | the node sees error 5 as haro's R35; the supervisor reads the job's messages | both seen |

Five consequences for the design:

1. **Loopback is closed to a container, slowly.** Even with internetClient, a connect to 127.0.0.1 waited about 21 s
   and failed. Lifting that needs an administrator's loopback exemption. A node therefore talks to its supervisor
   through inherited handles (a pipe or a file) and never through a local port, and the Foundry's channel design should
   assume that.
2. **The memory ceiling has two values.** A cold compile of the library peaks at 2.3 GB and a warm run at 233 MB.
   Rung B2 lowered the first: the supervisor compiles the library prefix outside the boundary, and the node's warm
   start inside, compiled on that prefix, peaks at 673 MB under a 1,024 MB ceiling. Later starts take 256 MB.
3. **The processor-time ceiling is coarse.** Windows checks it late, so it suits budgets of seconds and not hundreds
   of milliseconds. A wall-clock deadline stays with the supervisor's own timer.
4. **Grant the shared trees once.** The engine and the library are granted at install, about 4 s for the library.
   One capability SID shared by every node container would let one rule on the library serve all nodes: the
   supervisor would grant the capability, never the tree, at each node's birth. That shape is the next probe and is
   not measured here.
5. **The refusal the node sees is R35, "Can't create/open the file".** The record can say what was refused and
   where, but not that the operating system refused it. A Haro file error carrying the Windows error code would let a
   run record name the boundary. That is a question for the Haro desk.

## What to build, in order

1. **Rung B1, the spawn in the engine -- BUILT 2026-11-14**, below.
2. **Rung B2, install and removal -- BUILT 2026-11-14**, below.
3. **Rung B3, stzNodeSupervisor takes the grant -- BUILT 2026-11-14**, below.
4. **The shared capability SID** (consequence 4), measured before B2 is closed.

The Linux half stays HAROBANDA-WORKER-01.

## Rung B1, built

`engine/src/boundary.zig`, in stz_process. A grant is an id; its fields are set one call each, and a grant runs once.

    nG = StzEngineBoundaryNew("stz.node.shop")         a grant on that AppContainer profile (made on first use, kept)
    StzEngineBoundaryRead(nG, cPath)                    read and execute, a folder's tree or one file
    StzEngineBoundaryWrite(nG, cPath)                   full access; the path must exist
    StzEngineBoundaryNetwork(nG, 1)                     the internetClient capability
    StzEngineBoundaryChildren(nG, n)                    the job's active-process limit is 1 + n
    StzEngineBoundaryMemory(nG, nMB)                    the job's commit ceiling (256 by default)
    StzEngineBoundaryProcessor(nG, nSeconds)            the job's processor-time ceiling (none by default)
    StzEngineBoundaryOutput(nG, cStdout, cStderr)       NUL when empty; stdin is NUL
    StzEngineBoundaryStart(nG, cCommandLine)            -> the process id, 0 with StzEngineBoundaryError(nG)
    StzEngineBoundaryWait(nG, nMs)                      -> 1 ended, 0 still running
    StzEngineBoundaryExitCode / Messages / PeakMb / WallMs / GrantMs / Granted / End / Free
    StzEngineBoundaryHasRule(cName, cPath) / Revoke(cName, cPath) / DeleteProfile(cName)

Three choices the spike did not make:

- **The child inherits its three standard handles and nothing else** (`PROC_THREAD_ATTRIBUTE_HANDLE_LIST`). Without
  the list, every inheritable handle the supervisor holds would reach the node.
- **A rule is written once.** Before granting a path, start() reads its access list; when the list already gives the
  container that access, the path is left alone. The second start of a node pays nothing for its grant.
- **Closing a grant ends its run.** The job is created with kill-on-close, so a supervisor that frees a grant, or
  exits, leaves no node behind.

The guard is `base/test/security/os_boundary_spawn_narrated.haro`, 43 assertions over nine scenes, with haro.exe
itself as the node wherever a Haro program can show the reach. It ran in 43 s on haro.exe, with the engine built for
Haro from this commit's sources. Its first grant (profile and three folders) took 20 to 23 ms.

| scene | what the node did | what came back |
|---|---|---|
| reads and writes | read the granted file, wrote in its runs folder | reached |
| | read the stand-in key, read the guard's source, wrote beside the key | R35 in the node, nothing planted |
| network | curl to 1.1.1.1 without the capability | exit 7, status 000 |
| | the same with internetClient | the status the supervisor gets outside |
| children | SystemCmd under the default grant | no output, ACTIVE_PROCESS_LIMIT |
| | the same with two children counted | the shell's output, no limit message |
| memory | a string doubled to 512 MB under 256 MB | out of memory, JOB_MEMORY_LIMIT |
| processor time | a spinning node under 1 s | 0xC0000044, END_OF_JOB_TIME |
| ended | End() on a spinning node | 0xC000013A |
| grant once | a second start of the same node | 0 rules written |
| revoke | Revoke on the three folders | no rule left on them or on a file inside |

**One measured finding for the run record.** Windows' peak job memory counts the commit it refused. The memory node
held 143 MB and asked for 256 MB more under a 256 MB ceiling: the peak read 399 MB. At 512 MB it read 784 MB, at
128 MB 132 MB, and each time the allocation failed. So rung B3 writes the peak as *the most the node asked for*,
and reads JOB_MEMORY_LIMIT, not the peak, as the sign that a node met its ceiling.

## Rung B2, built

`base/security/stzNodeBoundary.haro`: `StzBoundaryInstall(vPlan)` and `StzBoundaryRemove(vPlan)`, over three engine
calls added to boundary.zig: `StzEngineBoundaryProfile(name)`, `StzEngineBoundaryGrantPath(name, path, bWrite)` and
`StzEngineBoundaryRulesLeft(name, path, nMax)` with `StzEngineBoundaryWalked()`. A plan names the profile, the read
paths, the write paths, the node's cache folder, the library root, haro.exe, the warm command and its ceiling.

The install does five things, in this order:

1. refuses a plan whose cache lies under a write path, before anything is made;
2. creates the profile and grants each read and write path, writing a rule only where none gives that access;
3. compiles the trusted library prefix (`haro prefix stzBase.ring`) OUTSIDE the boundary, into the node's cache;
4. runs the node's warm start INSIDE the boundary, with write on its cache for that one run, under 1,024 MB;
5. revokes the cache's write rule and grants read: the node uses its image and cannot rewrite it.

No code of the node's pack runs outside the boundary. The removal revokes every path the plan names, walks each tree
and counts the entries whose access list still names the container, and deletes the profile.

**Measured** by `base/test/security/os_boundary_install_narrated.haro`, 30 of 30 on haro.exe, with this checkout's
library tree (about 22,000 entries) and an engine copy granted for the run:

| step | measured |
|---|---|
| grants at install (profile, library, engine, haro's folder, the node's folders) | 755 ms |
| the library prefix, outside | 21.9 s |
| the warm start, inside, on the prefix | 0.39 s, peak 673 MB |
| a later start, inside, under 256 MB | 0.14 s, peak 233 MB, no rule written |
| the node writing its image, the prefix, a new image | each refused (R35) |
| a second install | 0 rules written |
| revoke of the six paths | 0.80 s |
| the walk of every tree, 22,392 entries | 0.51 s, 0 entries naming the container |
| the profile and its folder under %LOCALAPPDATA%\Packages | deleted |

Measured before the design, by probes:

- **A node compiled whole inside needs about 2.3 GB once** (23.6 s here), then 233 MB. Compiled on the prefix it
  needs 673 MB, and that peak is paid at every start when the node cannot keep its own image: a 512 MB ceiling
  failed. So the warm start keeps its image, and only then is the cache made read-only.
- **haro exits 0 when its compile fails for memory** ("compile failed: OutOfMemory" on its output, exit code 0). The
  install therefore reads JOB_MEMORY_LIMIT in the job's messages as a failed warm start, whatever the exit code. A
  question for the Haro desk.
- **Revoking a folder does not remove a rule written on a folder inside it.** Windows re-propagates the inherited
  rules and leaves explicit ones: a probe that had granted a folder and two of its subfolders separately kept five
  entries naming its container after revoking the folder. The removal revokes every path it granted, one by one, and
  the walk is what proves it.
- **A changed pack or library makes the image stale**, and the next start compiles again: on the prefix that is the
  673 MB above, without it the 2.3 GB, both over a 256 MB ceiling. So an update of either is a new install (rung B3
  decides when). This follows from the two measured peaks; the stale start itself was not run.

## Rung B3, built

`stzNodeSupervisor` (base/cluster) gains one declaration and one reading:

    oSup.Child("shop", "node.haro", 45810)
    oSup.ChildGrant("shop", [ :profile = "stz.node.shop", :reads = [...], :writes = [...],
                              :memoryMB = 256, :processorSeconds = 0, :output = "...", :cache = "...",
                              :interpreter = "...haro.exe" ])
    oSup.RunsOf("shop")      # the run records, newest last

A child with a grant is started inside its boundary at every start and restart; the strategy, the restart budget, the
monitors and the escalation apply to it unchanged. Its death is the end of the boundary's run; KillChild and StopAll
end the whole job. Each run leaves a record of pairs -- :pid, :exit, :messages, :limits, :peakMB, :wallMs, :error --
and the supervisor keeps the last twenty. A run whose job said JOB_MEMORY_LIMIT, END_OF_JOB_TIME or
ACTIVE_PROCESS_LIMIT is also written to the security ledger as **node.limit**, a warning from the supervisor about the
child, its origin the profile -- a new row of the closed catalogue. The supervisor sets the child's HARO_CACHE for the
start only.

A bounded child is never sent a heartbeat: the heartbeat is a request over the node plane on loopback, which a
container cannot reach, so its liveness is its process, and it talks to its supervisor through files.

**Measured** by `base/test/security/node_supervisor_bounded_narrated.haro`, 35 of 35 on haro.exe:

| scene | what came back |
|---|---|
| a child that exits at once, budget 2 | two restarts, three records each exit 0 and no limit, then escalation naming the child |
| memory past 256 MB | the record's limits name JOB_MEMORY_LIMIT; the ledger holds one node.limit, a warning from node-supervisor about the child |
| processor time past 1 s | END_OF_JOB_TIME, exit 0xC0000044; a second node.limit |
| KillChild | the death seen at the next Cycle, recorded with 0xC000013A |
| StopAll | the run recorded with 0xC000013A, the child holding no job |
| heartbeats on, a spinning bounded child | not taken for wedged: no run ended, no restart |
| a grant whose write path does not exist | each attempt recorded with exit -1 and the reason; the budget stops the retries |
| the child reads outside its grant | refused, through the supervisor as through B1 |

Two things the supervisor does not decide. **When to re-install**: a pack or library change makes the node's image
stale, and its next start meets JOB_MEMORY_LIMIT, which is now a node.limit record the caller can act on by running
StzBoundaryInstall again. **What the plain children's guard says on haro**: `test/cluster/d3_supervision_narrated.ring`
is 20 of 25 on haro.exe, with the same five failures with and without this rung (its children answer after boot too
late for its timeouts); the rung leaves plain children as they were.

