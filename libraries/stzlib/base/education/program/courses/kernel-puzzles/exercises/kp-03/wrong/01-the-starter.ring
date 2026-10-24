# The starter, untouched: no body yet.
k = StzKernelMakerQ()
k.TakesVector(:a)
k.TakesScalar(:alpha)
k.ReturnsVector(:c)
? StzKernelPuzzleQ("kp-03").Grade(k)
