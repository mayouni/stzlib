# Twice each element, in the task's own words.
k = StzKernelMakerQ()
k.TakesVector(:a)
k.ReturnsVector(:c)
k.ForEachElement('{ @c = @a * 2 }')
? StzKernelPuzzleQ("kp-01").Grade(k)
