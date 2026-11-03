# The starter, untouched: no body yet.
k = StzKernelMakerQ()
k.TakesVector(:a)
k.ReturnsVector(:c)
? StzKernelPuzzleQ("kp-18").Grade(k)
