# Windows that slide by one instead of by 16: right only for the first partial.
k = StzKernelMakerQ()
k.TakesVector(:a)
k.ReturnsVector(:c)
k.ForEachElement('{ @c = sum(k, 0, 16, @a[@i + k]) }')
? StzKernelPuzzleQ("kp-07").Grade(k)
