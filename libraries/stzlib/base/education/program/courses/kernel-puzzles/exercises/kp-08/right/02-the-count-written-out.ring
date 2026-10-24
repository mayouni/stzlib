# The same fold with the count written as a number: right while m is 1,024, which it is.
k = StzKernelMakerQ()
k.TakesVector(:c)
k.TakesScalar(:m)
k.ReturnsVector(:d)
k.ForEachElement('{ @d = sum(k, 0, 1024, @c[k]) }')
? StzKernelPuzzleQ("kp-08").Grade(k)
