# Counts the index from 1: wrong from the first element.
k = StzKernelMakerQ()
k.TakesVector(:a)
k.ReturnsVector(:c)
k.ForEachElement('{ @c = @a + @i + 1 }')
? StzKernelPuzzleQ("kp-04").Grade(k)
