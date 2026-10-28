# Each thread adds one to its candidate's counter.
k = StzKernelMakerQ()
k.TakesVector(:a)
k.ReturnsAtomic(:h, 13)
k.ForEachElement('{ @h[@a] += 1 }')
? StzKernelPuzzleQ("kp-17").Grade(k)
