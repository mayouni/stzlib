load "../../stzBase.ring"

nMB = 1024 * 1024

? "== block 1 =="
oMon = StzPerfMonitor("restolean")
oMon.WatchMemory().WatchCpu().Every(50)
mOrders = oMon.NewCounter("shop.orders")
mCheckout = oMon.NewTimer("shop.checkout.ms")

for i = 1 to 120
	w = StzStopwatch()
	_s_ = ""
	for j = 1 to 2000 + (i % 7) * 3000
		_s_ += "x"
	next
	mCheckout.RecordWatch(w)
	mOrders.Increment()
	oMon.Tick()
next
? "orders total : " + mOrders.Value()
? "orders rate  : " + mOrders.RatePerSecond() + " /s"
? "checkout p95 : " + mCheckout.P95() + " ms (bucket bound)"
? "checkout p95 : " + mCheckout.ExactPercentile(95) + " ms (exact, window)"
? "checkout mean: " + mCheckout.MeanMs() + " ms (exact lifetime)"

? "== block 2 =="
oMon.Show()

? "== block 3 =="
see oMon.Prometheus()

? "== block 4 =="
? left(oMon.OtelJson(), 160) + "..."

? "== block 5 =="
oMon2 = StzPerfMonitor("hosted")
oMon2.WatchMemory().Every(60)
oHost = new stzAgentHost()
oHost.Supervise(oMon2, 60)
oHost.RunFor(250)
? "host ticks   : " + oHost.TicksOf("hosted")
? "rss samples  : " + oMon2.MetricQ("process.memory.rss").Count()
? "rss now      : " + oMon2.MetricQ("process.memory.rss").Value() / nMB + " MB"

oMon.Destroy()
oMon2.Destroy()
