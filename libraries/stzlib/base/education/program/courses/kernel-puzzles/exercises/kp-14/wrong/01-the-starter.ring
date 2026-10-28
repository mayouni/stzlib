# The starter, untouched: no body yet.
k = StzKernelMakerQ()
k.TakesIntVector(:a)
k.ReturnsIntVector(:c)
? StzKernelPuzzleQ("kp-14").Grade(k)
