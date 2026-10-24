# The starter, untouched: no body yet. The puzzle starts red.
k = StzKernelMakerQ()
k.TakesVector(:a)
k.ReturnsVector(:c)
? StzKernelPuzzleQ("kp-01").Grade(k)
