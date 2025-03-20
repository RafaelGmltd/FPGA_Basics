## One cycle pulse detector

So, as soon as '010' is detected, the 'detected' signal becomes 1, but only for one clock cycle. 
After that, 'detected' becomes 0 again, making it a one-clock pulse.


| clk   | d |  q[2]  |  q[1]  |  q[0]  | detected |
|-------|---|--------|--------|--------|----------|
|   0   | 0 |   0    |   0    |   0    |    0     |
|   1   | 1 |   0    |   0    |   1    |    0     |
|   2   | 0 |   0    |   1    |   0    |    1 ✅  |
|   3   | 1 |   1    |   0    |   1    |    0     |
|   4   | 1 |   0    |   1    |   1    |    0     |
|   5   | 0 |   1    |   1    |   0    |    0     |
|   6   | 0 |   1    |   0    |   0    |    0     |

