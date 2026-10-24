# The starter, untouched: no body yet.
k = StzKernelMakerQ()
k.TakesVector(:a)
k.ReturnsVector(:c)
? StzKernelPuzzleQ("kp-04").Grade(k)
