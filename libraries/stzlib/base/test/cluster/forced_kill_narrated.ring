load "../../stzBase.ring"
load "../_narrated.ring"

# R8 FORCED KILL + ORPHAN CLEANUP -- the forceful sibling of graceful drain
# (resilience rung #5, the fleet-lifecycle closer). ScaleDown drains a worker
# (routing stops, it finishes in-flight, self-exits on TTL). But a WEDGED
# worker -- alive yet answering neither /health nor its TTL -- needs an
# OS-level kill. Backed by a new engine primitive (reactor_spawn_kill ->
# uv_process_kill, mutex-guarded against the loop thread): the cluster force-
# kills a hung worker, kills the old process BEFORE a restart (no orphan),
# and force-kills every spawned worker on Stop (nothing outlives the cluster).

# =====================================================================
#  UNIT: the reactor kill primitive (deterministic)
# =====================================================================

Scenario("killing an unknown job id is a clean error, not a crash")
	Given("a bare reactor")
	$oRx = new stzReactor()
	Then("SIGKILL to a non-existent job returns -2 (not found)",
		$oRx.KillSpawnHard(999999), -2)
	Then("SIGTERM to a non-existent job also returns -2",
		$oRx.KillSpawn(999999, 15), -2)
	$oRx.Destroy()
EndScenario()

# =====================================================================
#  DETERMINISTIC: ForceKill respects ownership (no spawn)
# =====================================================================

Scenario("ForceKill skips workers it does not own")
	Given("a cluster with a declared-but-unstarted facet + an external worker")
	$oD = new stzAppCluster()
	$oD.WithFacet(:graph, 2)                          # 2 workers, jobId 0 (not started)
	$oD.RegisterExternalWorker(:graph, "127.0.0.1", 9)  # external, jobId 0
	When("ForceKill is called before anything is spawned")
	n = $oD.ForceKill("graph")
	Then("nothing was killed (unstarted + external are not ours)", n, 0)
	Then("the kill count stays zero", $oD.KilledCount(), 0)
EndScenario()

# =====================================================================
#  LIVE: force-kill a running worker, then self-heal
# =====================================================================

Scenario("LIVE: a running worker is force-killed and stops answering")
	Given("one real nlp worker, serving")
	$nB1 = 42000 + (StzEngineTimeNowMs() % 500)
	$oK = new stzAppCluster()
	$oK.WithNLP(1).WithWorkerTTL(30000).WithBasePort($nB1)
	$oK.Start()
	Then("it comes ready", $oK.WaitReady(25000), 1)
	Then("it serves a request", StzFindFirst($oK.Route("nlp", "/work?q=hi"), "nlp:done:hi") > 0, TRUE)

	When("the worker is force-killed")
	nKilled = $oK.ForceKill("nlp")
	Then("exactly one worker was killed", nKilled, 1)
	Then("the kill count reflects it", $oK.KilledCount(), 1)

	When("we let the OS reap it and re-probe health")
	nJ = $oK.ReactorQ().SubmitTimer(700)
	$oK.ReactorQ().AwaitTimer(nJ, 1500)
	Then("no worker answers health now", $oK.HealthCheck(), 0)
	Then("routing declines (the worker is gone)", $oK.Route("nlp", "/work?q=x"), "")
	Then("with a negative status", $oK.RouteLastStatus() < 0, TRUE)

	When("RestartDead self-heals the fleet")
	nR = $oK.RestartDead()
	Then("one worker was restarted", nR, 1)
	Then("the already-dead old process was NOT double-counted as killed",
		$oK.KilledCount(), 1)
	Then("the fresh worker comes ready", $oK.WaitReady(25000), 1)
	Then("and serves again", StzFindFirst($oK.Route("nlp", "/work?q=back"), "nlp:done:back") > 0, TRUE)

	When("ForceKill is called a SECOND time on the (now live) worker then AGAIN")
	$oK.ForceKill("nlp")
	nKilled2 = $oK.ForceKill("nlp")   # already dead -> idempotent
	Then("a re-kill of an already-dead worker kills nothing (idempotent)", nKilled2, 0)
	$oK.Stop()
EndScenario()

# =====================================================================
#  LIVE: Stop performs orphan cleanup (nothing outlives the cluster)
# =====================================================================

Scenario("LIVE: Stop force-kills every spawned worker (orphan cleanup)")
	Given("a cluster with TWO live workers")
	$nB2 = 42600 + (StzEngineTimeNowMs() % 400)
	$oS = new stzAppCluster()
	$oS.WithNLP(2).WithWorkerTTL(30000).WithBasePort($nB2)
	$oS.Start()
	Then("both come ready", $oS.WaitReady(25000), 2)
	Then("no kills yet", $oS.KilledCount(), 0)

	When("the cluster is stopped")
	$oS.Stop()
	Then("Stop force-killed both live worker processes (orphan cleanup)",
		$oS.KilledCount(), 2)
EndScenario()

Summary()
