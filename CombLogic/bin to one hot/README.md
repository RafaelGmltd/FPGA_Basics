# *Bin to One hot*

in_to_onehot module, converts a binary input into a one-hot encoded output.

Input bin — a binary number (e.g., 3-bit).
Output onehot — a one-hot encoded value (8-bit, where only one bit is set to 1).

The width of the output onehot is determined by the expression:

``` output logic [(1<<WIDTH)-1:0] onehot```                                                                                                                          

| WIDTH | 1 << WIDTH | Output Bit Width |
|-------|----------- |------------------|
| 1     | 1 << 1 = 2 | [1:0]            |
| 2     | 1 << 1 = 4 | [3:0]            |
| 3     | 1 << 1 = 8 | [7:0]            |
| 4     | 1 << 1 = 16| [15:0]           |
| 5     | 1 << 1 = 32| [31:0]           |

<< is the left shift operator in Verilog.

```1 << WIDTH``` means: "Shift the number 1 to the left by WIDTH bits," which is mathematically equivalent to 
```2^WIDTH```
For example, if ```WIDTH = 3``` →  ```1 << 3 → 2^3 = 8.``` 
This means the output vector will be 8 bits wide ```(onehot[7:0])```

For `WIDTH = 3`, the mapping is:

| Binary Input (bin)| One-Hot Output (onehot)|
|-------------------|------------------------|
| 000 (0)           | 00000001 (1)           |
| 001 (1)           | 00000010 (2)           |
| 010 (2)           | 00000100 (4)           |
| 011 (3)           | 00001000 (8)           |
| 100 (4)           | 00010000 (16)          |
| 101 (5)           | 00100000 (32)          |
| 110 (6)           | 01000000 (64)          |
| 111 (7)           | 10000000 (128)         |