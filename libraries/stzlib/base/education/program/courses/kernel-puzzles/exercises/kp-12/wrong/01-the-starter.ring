# The starter, untouched: no body yet.
k = StzKernelMakerQ()
k.TakesVector(:a)
k.TakesVector(:b)
k.TakesScalar(:alpha)
k.ReturnsVector(:c)
? StzKernelPuzzleQ("kp-12").Grade(k)
