# @i is the thread's own element number, from 0.
k = StzKernelMakerQ()
k.TakesVector(:a)
k.ReturnsVector(:c)
k.ForEachElement('{ @c = @a + @i }')
? StzKernelPuzzleQ("kp-04").Grade(k)
