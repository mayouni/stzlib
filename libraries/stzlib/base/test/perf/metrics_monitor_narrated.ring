# Metrics and the monitor -- perf system P2 (SOFTANZA_PERF_SYSTEM.md).
#
# stzMetric: three kinds over engine-resident state -- counter (with
# measured rate = throughput X), gauge (with the slope trend), timer
# (streaming bucket percentiles AND exact window percentiles, exact
# lifetime sum/mean via the histogram's new engine-side sum).
# stzPerfMonitor: watch declarations + cadence, three run modes (pull /
# tick / hosted as an agent on a real stzAgentHost), and the industry
# formats: Prometheus exposition text + one OTLP resourceMetrics
# envelope.
#
# The design rule under test in Scene 3: ALL metric state lives in the
# engine, so the copies Ring makes on assignment are second faces on
# the SAME truth -- record through the copy, read through the original.
#
# Ring traps avoided: main code before the first func; helper temps
# underscored; no local oR / nL / Try / Show.

load "../../stzBase.ring"

nPass = 0
nFail = 0

nMB = 1024 * 1024

pr()

? "-- Scene 1: a counter counts, and knows its own rate --"
c = StzMetric("app.requests", :Counter)
for i = 1 to 50
	c.Increment()
next
c.IncrementBy(50)
chk("Value() is the cumulative total (100)", c.Value() = 100)
chk("Count() saw 51 recordings", c.Count() = 51)
nRate = c.RatePerSecond()
? "  measured rate = " + nRate + " events/s"
chk("RatePerSecond() is positive (events DID arrive over time)", nRate > 0)
chk("kind predicates agree", c.IsCounter() and NOT c.IsGauge())

? ""
? "-- Scene 2: a gauge levels, a timer distributes --"
g = StzMetric("queue.depth", :Gauge)
g.Set(10)
g.Set(30)
g.Set(20)
chk("gauge Value() is the last level", g.Value() = 20)
chk("gauge Mean()/Min()/Max() exact", g.Mean() = 20 and g.Min() = 10 and g.Max() = 30)

t = StzMetric("checkout.duration", :Timer)
t.Record(12.5)
t.Record(3)
t.Record(48)
t.Record(0.4)
chk("timer Count() = 4", t.Count() = 4)
chk("timer SumMs() is EXACT (63.9, though buckets quantize)", fabs(t.SumMs() - 63.9) < 0.000001)
chk("timer MeanMs() is exact lifetime mean", fabs(t.MeanMs() - 15.975) < 0.000001)
? "  p95 (bucket bound) = " + t.P95() + " ; exact p95 (window) = " + t.ExactPercentile(95)
chk("P95 bucket bound covers the true p95", t.P95() >= t.ExactPercentile(95))
chk("ExactPercentile(100) is the true max", t.ExactPercentile(100) = 48)

? ""
? "-- Scene 3: a Ring COPY is a second face on the SAME truth --"
t2 = t
t2.Record(100)
chk("recorded through the copy, visible in the original", t.Count() = 5)
chk("...sum too", fabs(t.SumMs() - 163.9) < 0.000001)
c2 = c
c2.Increment()
chk("counter total shared across faces", c.Value() = 101)

# The trap this design survived: a FRESH metric copied BEFORE any
# recording. Engine handles are materialized eagerly at birth --
# a lazily-created handle would be created per-copy, silently
# forking the metric (found live: the registry face read 0 while
# the recording face read 120).
tFresh = StzMetric("fresh.timer", :Timer)
tFork = tFresh
tFork.Record(9)
chk("a FRESH timer copy still shares (eager handles beat the fork)", tFresh.Count() = 1)
tFresh.Destroy()

? ""
? "-- Scene 4: the monitor samples the senses on declaration --"
oMon = StzPerfMonitor("guard-app")
oMon.WatchMemory().WatchCpu().WatchSystemMemory().Every(40)
chk("watch declarations registered 4 metrics", oMon.NumberOfMetrics() = 4)
oMon.Sample()
_s_ = ""
for i = 1 to 200000
	_s_ += "x"
next
oMon.Sample()
chk("two samples taken", oMon.SampleCount() = 2)
nRss = oMon.MetricQ("process.memory.rss").Value()
? "  sampled rss = " + (nRss / nMB) + " MB"
chk("rss gauge holds a real weight (> 5MB)", nRss > 5 * nMB)
chk("peak gauge >= rss gauge", oMon.MetricQ("process.memory.peak").Value() >= nRss)
nU = oMon.MetricQ("process.cpu.utilization").Value()
? "  sampled utilization = " + nU
chk("utilization sampled on the SECOND pass (needs a delta), in [0,1]", nU >= 0 and nU <= 1)
chk("system free memory sampled (> 0)", oMon.MetricQ("system.memory.free").Value() > 0)

? ""
? "-- Scene 5: Tick() honors the cadence --"
oMon.Every(100)
nT1 = oMon.Tick()
nT2 = oMon.Tick()
chk("first Tick() sampled (due), immediate second did not", nT1 = 1 and nT2 = 0)
StzEngineTimeSleepMs(120)
chk("after the interval, Tick() sampled again", oMon.Tick() = 1)

? ""
? "-- Scene 6: RunFor() drives the cadence by itself --"
nBefore = oMon.SampleCount()
oMon.Every(50)
oMon.RunFor(320)
nTaken = oMon.SampleCount() - nBefore
? "  320ms at a 50ms cadence -> " + nTaken + " samples"
chk("roughly the right number of samples (4..8)", nTaken >= 4 and nTaken <= 8)

? ""
? "-- Scene 7: the monitor IS an agent -- hosted on a real stzAgentHost --"
oMon2 = StzPerfMonitor("hosted-mon")
oMon2.WatchMemory().Every(60)
oHost = new stzAgentHost()
oHost.Supervise(oMon2, 60)
oHost.RunFor(280)
nTicks = oHost.TicksOf("hosted-mon")
? "  host ticked the monitor " + nTicks + " time(s) in 280ms at 60ms"
chk("the host supervised the monitor like any agent (>= 3 ticks)", nTicks >= 3)
chk("...and the hosted copy sampled into the SHARED engine gauges", oMon2.MetricQ("process.memory.rss").Count() >= 3)

? ""
? "-- Scene 8: your own metrics live in the same registry --"
oMon3 = StzPerfMonitor("shop")
mReq = oMon3.NewCounter("shop.orders")
mReq.IncrementBy(7)
oMon3.NewTimer("shop.checkout.ms").Record(24).Record(141)
chk("counter registered and shared (7 through either face)", oMon3.MetricQ("shop.orders").Value() = 7)
chk("timer registered, 2 samples", oMon3.MetricQ("shop.checkout.ms").Count() = 2)

? ""
? "-- Scene 9: Prometheus exposition -- the /metrics handshake --"
cProm = oMon3.Prometheus()
? "  --- exposition ---"
see cProm
? "  ------------------"
chk("counter exports with _total and TYPE counter", StzFindFirst("# TYPE shop_orders_total counter", cProm) > 0)
chk("counter sample line present", StzFindFirst("shop_orders_total 7", cProm) > 0)
chk("timer exports as a summary", StzFindFirst("# TYPE shop_checkout_ms summary", cProm) > 0)
chk("quantile lines present", StzFindFirst('shop_checkout_ms{quantile="0.95"}', cProm) > 0)
chk("_sum is the exact sum (165)", StzFindFirst("shop_checkout_ms_sum 165", cProm) > 0)
chk("_count present", StzFindFirst("shop_checkout_ms_count 2", cProm) > 0)
chk("dots folded to underscores (prometheus naming)", StzFindFirst("shop.orders", cProm) = 0)

? ""
? "-- Scene 10: one OTLP envelope batches every metric --"
cOtel = oMon3.OtelJson()
chk("resourceMetrics envelope present", StzFindFirst('"resourceMetrics"', cOtel) > 0)
chk("service.name carries the monitor's name", StzFindFirst('"stringValue":"shop"', cOtel) > 0)
chk("counter is a monotonic sum", StzFindFirst('"isMonotonic":true', cOtel) > 0)
chk("timer is a summary with quantileValues", StzFindFirst('"quantileValues"', cOtel) > 0)
chk("keeps OTel names un-folded (shop.orders)", StzFindFirst('"name":"shop.orders"', cOtel) > 0)

? ""
? "-- Scene 11: wrong-kind calls refuse with a teaching message --"
bRaised = FALSE
try
	g.Increment()
catch
	bRaised = TRUE
done
chk("Increment() on a gauge refuses", bRaised)
bRaised = FALSE
try
	c.P95()
catch
	bRaised = TRUE
done
chk("P95() on a counter refuses", bRaised)

oMon.Destroy()
oMon2.Destroy()
oMon3.Destroy()
c.Destroy()
g.Destroy()
t.Destroy()

? ""
? "=========================================="
? "TOTAL: " + (nPass + nFail) + " assertions, " + nPass + " pass, " + nFail + " fail"
? "=========================================="

pf()

func chk cLabel, bCond
	if bCond
		nPass++
		? "  [OK] " + cLabel
	else
		nFail++
		? "  [FAIL] " + cLabel
	ok

func fabs n
	if n < 0 return -n ok
	return n
