load "../../stzBase.ring"

? "== the R-vs-X curve, driven for real =="
oL = StzLoadDriver()
oL.SetBusyMs(3).SetRequestsPerDriver(25)
oL.SpawnTarget(0)
oL.Curve([ 1, 3, 8 ])
oL.Show()
oL.Destroy()
