# The starter, untouched: no body yet.
k = StzKernelMakerQ()
k.TakesVector(:c)
k.TakesScalar(:m)
k.ReturnsVector(:d)
? StzKernelPuzzleQ("kp-08").Grade(k)
