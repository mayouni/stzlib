# The starter, untouched: no body yet.
k = StzKernelMakerQ()
k.TakesVector(:a)
k.TakesVector(:b)
k.TakesVector(:x)
k.ReturnsVector(:y)
? StzKernelPuzzleQ("kp-24").Grade(k)
