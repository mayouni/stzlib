# Start at a half, double on every pass, and stop as soon as the state holds the size.
k = StzKernelMakerQ()
k.TakesVector(:a)
k.ReturnsVector(:c)
k.ForEachElement('{ @c = iterate(k, 0, 40, s, 0.5, s * 2, s >= @a) }')
? StzKernelPuzzleQ("kp-18").Grade(k)
