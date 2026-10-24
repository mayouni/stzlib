# The starter, untouched: no body yet.
k = StzKernelMakerQ()
k.TakesVector(:a)
k.TakesVector(:b)
k.ReturnsVector(:c)
? StzKernelPuzzleQ("kp-02").Grade(k)
