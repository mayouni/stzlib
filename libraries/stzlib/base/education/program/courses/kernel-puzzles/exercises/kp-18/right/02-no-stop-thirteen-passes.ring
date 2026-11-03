# No stop: thirteen passes always, checking BEFORE it doubles, so it starts at 1 (a stop is read after a pass; this form is not). 2^13 is 8192, past every size here.
k = StzKernelMakerQ()
k.TakesVector(:a)
k.ReturnsVector(:c)
k.ForEachElement('{ @c = iterate(k, 0, 13, s, 1, when(s >= @a, s, s * 2)) }')
? StzKernelPuzzleQ("kp-18").Grade(k)
