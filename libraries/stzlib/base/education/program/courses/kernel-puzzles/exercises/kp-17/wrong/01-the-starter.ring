# The starter, untouched: no body yet.
k = StzKernelMakerQ()
k.TakesVector(:a)
k.ReturnsAtomic(:h, 13)
? StzKernelPuzzleQ("kp-17").Grade(k)
