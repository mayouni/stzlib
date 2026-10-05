# THE ORACLE FOR THE TUKEY SMOOTHERS (MATH-R-ORACLE-01, answered 2026-09-26):
# R's stats::smooth on fixed inputs, printed verbatim. The gate reads the
# transcript this script writes; nothing here is computed by the library.
#   Rscript r_smooth.R > r_smooth.txt
options(digits = 15)
cat("R.version.string:", R.version.string, "\n")
show <- function(tag, v) cat(tag, ":", paste(format(as.numeric(v), digits = 15), collapse = " "), "\n")
x <- c(4, 1, 3, 6, 6, 4, 1, 6, 2, 4, 2)          # R's own ?smooth example
y <- c(1, 2, 3, 4, 100, 6, 7, 8, 9, 10)          # a wild point on a ramp
p <- as.numeric(presidents); p[is.na(p)] <- 0    # R's presidents series, NAs as 0, n = 120
show("x", x); show("y", y); show("p", p)
for (nm in c("x", "y", "p")) {
  v <- get(nm)
  for (k in c("3", "3R", "S", "3RSS", "3RS3R", "3RSR")) {
    for (er in c("Tukey", "copy")) {
      show(paste(nm, k, er, "twice=0"), smooth(v, kind = k, endrule = er))
      show(paste(nm, k, er, "twice=1"), smooth(v, kind = k, endrule = er, twiceit = TRUE))
    }
  }
  show(paste(nm, "runmed3"), runmed(v, 3))
  show(paste(nm, "runmed5"), runmed(v, 5))
  show(paste(nm, "hanning-interior"), stats::filter(v, c(0.25, 0.5, 0.25)))
  # even-span running medians by R's median() per window, for 4253H's 4 and 2
  n <- length(v)
  show(paste(nm, "median4-windows"), sapply(seq_len(n - 3), function(i) median(v[i:(i + 3)])))
  show(paste(nm, "median2-windows"), sapply(seq_len(n - 1), function(i) median(v[i:(i + 1)])))
}
# a sweep of seeded integer series with ties and plateaus, every kind, both end rules
set.seed(20260926)
for (c in 1:40) {
  n <- sample(7:30, 1)
  v <- sample(0:9, n, replace = TRUE)
  show(paste("case", c, "input"), v)
  for (k in c("3", "3R", "S", "3RSS", "3RS3R", "3RSR")) {
    for (er in c("Tukey", "copy")) {
      show(paste("case", c, k, er), smooth(v, kind = k, endrule = er))
    }
  }
  show(paste("case", c, "3RS3R Tukey twice"), smooth(v, twiceit = TRUE))
}
