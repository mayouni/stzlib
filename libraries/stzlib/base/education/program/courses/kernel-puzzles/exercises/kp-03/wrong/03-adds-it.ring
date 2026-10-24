# Adds the parameter instead of multiplying by it.
k = StzKernelMakerQ()
k.TakesVector(:a)
k.TakesScalar(:alpha)
k.ReturnsVector(:c)
k.ForEachElement('{ @c = alpha + @a }')
? StzKernelPuzzleQ("kp-03").Grade(k)
