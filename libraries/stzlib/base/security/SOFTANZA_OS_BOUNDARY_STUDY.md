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
second run reused that second image. So a node pays one cold compile per container identity unless its cache is
warmed inside that container.

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
2. **The memory ceiling has two values.** A cold compile of the library peaks at 2.3 GB and a warm run at 233 MB. The
   supervisor warms each node's image once, inside the node's own container at install, with a generous ceiling, and
   then starts the node with the tight one.
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

1. **Rung B1, the spawn in the engine:** a function in stz_process that takes a grant and returns a handle, with a
   wait that answers the exit code, the job messages and the peak memory. The grant has these fields: name (the
   profile), read paths, write paths, network (internetClient or none), children (none, or a count), memory MB,
   processor seconds, and the stdout and stderr files. Its guard is the spike's table turned into assertions.
2. **Rung B2, install and removal:** create the profile, grant the shared trees, warm the image inside the container,
   and the reverse (revoke, delete the profile). The revoke must leave no container rule behind, checked as this study
   checked it.
3. **Rung B3, stzNodeSupervisor takes the grant**, passed unchanged from the Foundry's AF7 data, and writes the job's
   messages into the run record.
4. **The shared capability SID** (consequence 4), measured before B2 is closed.

The Linux half stays HAROBANDA-WORKER-01.
