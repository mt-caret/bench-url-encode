# bench-url-encode

The following code benchmarks the `HTTP` package's url encode functions
against the one in `http-types` while also performing some random tests to
make sure that outputs match. `alice-in-wonderland` is, well, text from
alice in wonderland, and `wagahaiwa-nekodearu` is a Japanese classic meant
to test CJK-heavy strings.

output:
```
━━━ check old an new encodings match ━━━
  ✓ propOldAndNewMatchAscii passed 100 tests.
  ✓ propOldAndNewMatchLatin1 passed 100 tests.
  ✓ propOldAndNewMatchUnicode passed 100 tests.
  ✓ propOldAndNewMatchUnicodeAll passed 100 tests.
  ✓ 4 succeeded.
benchmarking alice-in-wonderland/oldUrlEncode (HTTP)
time                 2.124 ms   (2.102 ms .. 2.160 ms)
                     0.997 R²   (0.995 R² .. 1.000 R²)
mean                 2.127 ms   (2.101 ms .. 2.216 ms)
std dev              130.5 μs   (50.63 μs .. 269.3 μs)
variance introduced by outliers: 45% (moderately inflated)

benchmarking alice-in-wonderland/newUrlEncode (http-types)
time                 2.820 ms   (2.782 ms .. 2.864 ms)
                     0.998 R²   (0.996 R² .. 0.999 R²)
mean                 2.879 ms   (2.852 ms .. 2.929 ms)
std dev              115.1 μs   (79.72 μs .. 194.4 μs)
variance introduced by outliers: 24% (moderately inflated)

benchmarking alice-in-wonderland/customUrlEncode
time                 7.023 ms   (6.915 ms .. 7.139 ms)
                     0.998 R²   (0.996 R² .. 0.999 R²)
mean                 6.957 ms   (6.875 ms .. 7.046 ms)
std dev              248.0 μs   (195.8 μs .. 323.3 μs)
variance introduced by outliers: 16% (moderately inflated)

benchmarking wagahaiwa-nekodearu/oldUrlEncode (HTTP)
time                 38.26 ms   (37.86 ms .. 38.56 ms)
                     1.000 R²   (0.998 R² .. 1.000 R²)
mean                 39.28 ms   (38.81 ms .. 40.39 ms)
std dev              1.293 ms   (547.1 μs .. 2.187 ms)

benchmarking wagahaiwa-nekodearu/newUrlEncode (http-types)
time                 76.08 ms   (75.19 ms .. 76.88 ms)
                     1.000 R²   (1.000 R² .. 1.000 R²)
mean                 76.15 ms   (75.64 ms .. 76.50 ms)
std dev              749.3 μs   (454.1 μs .. 1.149 ms)

benchmarking wagahaiwa-nekodearu/customUrlEncode
time                 200.7 ms   (190.7 ms .. 212.6 ms)
                     0.997 R²   (0.982 R² .. 1.000 R²)
mean                 209.7 ms   (203.4 ms .. 218.7 ms)
std dev              10.53 ms   (4.168 ms .. 16.56 ms)
variance introduced by outliers: 14% (moderately inflated)
```
