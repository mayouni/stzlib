# The same mean, the neighbours in the other order.
k = StzKernelMakerQ()
k.TakesVector(:a)
k.ReturnsVector(:c)
k.Guard('{ @i > 0 and @i < n - 1 }')
k.ForEachElement('{ @c = (@a[@i + 1] + @a + @a[@i - 1]) / 3 }')
? StzKernelPuzzleQ("kp-06").Grade(k)
