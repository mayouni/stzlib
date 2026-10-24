# Averages the two neighbours and forgets the element itself.
k = StzKernelMakerQ()
k.TakesVector(:a)
k.ReturnsVector(:c)
k.Guard('{ @i > 0 and @i < n - 1 }')
k.ForEachElement('{ @c = (@a[@i - 1] + @a[@i + 1]) / 2 }')
? StzKernelPuzzleQ("kp-06").Grade(k)
