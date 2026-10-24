# Without the edge guard the two edges are written (a neighbour outside reads 0): the task leaves them, so element 1 is the mismatch.
k = StzKernelMakerQ()
k.TakesVector(:a)
k.ReturnsVector(:c)
k.ForEachElement('{ @c = (@a[@i - 1] + @a + @a[@i + 1]) / 3 }')
? StzKernelPuzzleQ("kp-06").Grade(k)
