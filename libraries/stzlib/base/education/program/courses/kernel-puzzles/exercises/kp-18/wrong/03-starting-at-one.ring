# Starts at 1 and always runs one pass before it looks: a size of 0 gets 2, and the first element is wrong.
k = StzKernelMakerQ()
k.TakesVector(:a)
k.ReturnsVector(:c)
k.ForEachElement('{ @c = iterate(k, 0, 40, s, 1, s * 2, s >= @a) }')
? StzKernelPuzzleQ("kp-18").Grade(k)
