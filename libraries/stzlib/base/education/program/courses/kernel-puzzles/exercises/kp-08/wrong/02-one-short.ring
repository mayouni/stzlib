# Folds m - 1 partials: the last one is missing from the total.
k = StzKernelMakerQ()
k.TakesVector(:c)
k.TakesScalar(:m)
k.ReturnsVector(:d)
k.ForEachElement('{ @d = sum(k, 0, m - 1, @c[k]) }')
? StzKernelPuzzleQ("kp-08").Grade(k)
