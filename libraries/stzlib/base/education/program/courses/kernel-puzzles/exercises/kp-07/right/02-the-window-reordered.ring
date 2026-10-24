# The same window, the index written the other way round.
k = StzKernelMakerQ()
k.TakesVector(:a)
k.ReturnsVector(:c)
k.ForEachElement('{ @c = sum(k, 0, 16, @a[k + @i * 16]) }')
? StzKernelPuzzleQ("kp-07").Grade(k)
