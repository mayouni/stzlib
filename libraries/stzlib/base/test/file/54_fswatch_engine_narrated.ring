load "../../stzBase.ring"
load "../_narrated.ring"

# Engine-backed folder watcher. A worker thread snapshots the
# directory at 250ms intervals and queues ADD / MOD / DEL events
# the Ring side drains via Drain(). We exercise real FS state in
# a scratch directory; this is local-only IO (no network), allowed
# under the L99 guardrail.

Scenario("Engine fswatch helpers exist")
    Then("StzEngineFsWatchStart defined",
        isString(@@(:StzEngineFsWatchStart)),    TRUE)
    Then("StzEngineFsWatchPoll defined",
        isString(@@(:StzEngineFsWatchPoll)),     TRUE)
    Then("StzEngineFsWatchStop defined",
        isString(@@(:StzEngineFsWatchStop)),     TRUE)
    Then("StzEngineFsWatchLastError defined",
        isString(@@(:StzEngineFsWatchLastError)), TRUE)
EndScenario()

Scenario("Watch a fresh directory and pick up an ADD event")
    Given("a scratch directory")
    cDir = "_fswatch_scratch"
    if NOT dirExists(cDir) makedir(cDir) ok
    # Clean any stale scratch file from a previous run.
    if fexists(cDir + "/hello.txt") remove(cDir + "/hello.txt") ok
    o = new stzFolderWatcher
    o.Watch(cDir)
    Then("IsRunning is TRUE",      o.IsRunning(),  TRUE)
    Then("LastError is empty",     o.LastError(),  "")

    When("a new file appears in the directory")
    write(cDir + "/hello.txt", "hi")
    # Wait long enough for the worker to tick.
    nStart = clock()
    while (clock() - nStart) * 1000 / clocksPerSecond() < 600 end

    aEv = o.Drain()
    bSawAdd = FALSE
    nLe = len(aEv)
    for _i_ = 1 to nLe
        if aEv[_i_][:kind] = "ADD" and aEv[_i_][:name] = "hello.txt"
            bSawAdd = TRUE
        ok
    next
    Then("the ADD event surfaced", bSawAdd, TRUE)

    o.Stop()
    Then("IsRunning is FALSE after Stop", o.IsRunning(), FALSE)

    # Cleanup -- Ring doesn't ship removedir(); leave the scratch
    # directory in place for the local dev box. Subsequent runs of
    # this scenario re-use it.
EndScenario()

Scenario("Stop on a never-started watcher is a no-op")
    Given("a fresh watcher that never called Watch()")
    o2 = new stzFolderWatcher
    Then("IsRunning is FALSE", o2.IsRunning(), FALSE)
    o2.Stop()
    Then("IsRunning is still FALSE", o2.IsRunning(), FALSE)
EndScenario()

Summary()
