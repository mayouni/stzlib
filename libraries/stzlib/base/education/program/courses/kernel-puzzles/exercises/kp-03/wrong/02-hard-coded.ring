# Writes the number instead of reading the parameter: right only while alpha happens to be 2 -- it is 2.5.
k = StzKernelMakerQ()
k.TakesVector(:a)
k.TakesScalar(:alpha)
k.ReturnsVector(:c)
k.ForEachElement('{ @c = @a * 2 }')
? StzKernelPuzzleQ("kp-03").Grade(k)
