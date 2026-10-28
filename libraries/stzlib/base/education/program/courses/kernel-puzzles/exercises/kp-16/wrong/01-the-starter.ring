# The starter, untouched: no body yet.
k = StzKernelMakerQ()
k.TakesVectorOf(:p, :vec2)
k.TakesScalar(:c)
k.TakesScalar(:s)
k.ReturnsVectorOf(:q, :vec2)
? StzKernelPuzzleQ("kp-16").Grade(k)
