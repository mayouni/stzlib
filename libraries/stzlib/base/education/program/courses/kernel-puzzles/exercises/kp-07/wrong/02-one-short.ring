# Sums 15 of the 16: wrong from the first partial.
k = StzKernelMakerQ()
k.TakesVector(:a)
k.ReturnsVector(:c)
k.ForEachElement('{ @c = sum(k, 0, 15, @a[@i * 16 + k]) }')
? StzKernelPuzzleQ("kp-07").Grade(k)
