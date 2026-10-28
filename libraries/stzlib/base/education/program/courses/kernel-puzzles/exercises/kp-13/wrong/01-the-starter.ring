# The starter, untouched: no body yet.
k = StzKernelMakerQ()
k.TakesVector(:a)
k.TakesScalar(:t)
k.ReturnsVector(:c)
? StzKernelPuzzleQ("kp-13").Grade(k)
