# The starter, untouched: no body yet.
k = StzKernelMakerQ()
k.TakesVector(:a)
k.ReturnsVector(:c)
k.Shared(:m, 256)
k.Shared(:s, 256)
? StzKernelPuzzleQ("kp-11").Grade(k)
