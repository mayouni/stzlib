# The wrong operator: three times each element. Named at the first element that differs.
k = StzKernelMakerQ()
k.TakesVector(:a)
k.ReturnsVector(:c)
k.ForEachElement('{ @c = @a * 3 }')
? StzKernelPuzzleQ("kp-01").Grade(k)
