# Each thread sums its own window of 16: a thousand partial sums at once.
k = StzKernelMakerQ()
k.TakesVector(:a)
k.ReturnsVector(:c)
k.ForEachElement('{ @c = sum(k, 0, 16, @a[@i * 16 + k]) }')
? StzKernelPuzzleQ("kp-07").Grade(k)
