# Writes the index and never reads a: right at element 1 (0 + 0), wrong from element 2.
k = StzKernelMakerQ()
k.TakesVector(:a)
k.ReturnsVector(:c)
k.ForEachElement('{ @c = @i }')
? StzKernelPuzzleQ("kp-04").Grade(k)
