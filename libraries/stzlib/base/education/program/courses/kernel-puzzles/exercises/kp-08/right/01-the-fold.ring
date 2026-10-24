# One thread folds the m partials into the total.
k = StzKernelMakerQ()
k.TakesVector(:c)
k.TakesScalar(:m)
k.ReturnsVector(:d)
k.ForEachElement('{ @d = sum(k, 0, m, @c[k]) }')
? StzKernelPuzzleQ("kp-08").Grade(k)
