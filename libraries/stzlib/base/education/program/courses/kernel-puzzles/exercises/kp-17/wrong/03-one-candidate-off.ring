# Every vote lands one counter early, and votes for 0 are dropped: wrong at element 5.
k = StzKernelMakerQ()
k.TakesVector(:a)
k.ReturnsAtomic(:h, 13)
k.ForEachElement('{ @h[@a - 1] += 1 }')
? StzKernelPuzzleQ("kp-17").Grade(k)
