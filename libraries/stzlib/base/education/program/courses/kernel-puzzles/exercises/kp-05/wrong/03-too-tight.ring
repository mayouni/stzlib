# A guard that stops one element early leaves element 4000 unwritten.
k = StzKernelMakerQ()
k.TakesVector(:a)
k.ReturnsVector(:c)
k.Guard('{ @i < n - 1 }')
k.ForEachElement('{ @c = @a * 2 }')
? StzKernelPuzzleQ("kp-05").Grade(k)
