# Copies the first partial and calls it the total.
k = StzKernelMakerQ()
k.TakesVector(:c)
k.TakesScalar(:m)
k.ReturnsVector(:d)
k.ForEachElement('{ @d = @c }')
? StzKernelPuzzleQ("kp-08").Grade(k)
