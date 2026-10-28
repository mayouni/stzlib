# Each thread adds its vote's NUMBER, made whole: candidate 0 gets nothing, wrong at element 1.
k = StzKernelMakerQ()
k.TakesVector(:a)
k.ReturnsAtomic(:h, 13)
k.ForEachElement('{ @h[@a] += int(@a) }')
? StzKernelPuzzleQ("kp-17").Grade(k)
