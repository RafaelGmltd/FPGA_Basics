# *MATRIX*

Matrix, a set of numbers arranged in rows and columns so as to form a rectangular array. The numbers are called the elements, or entries, of the matrix.
If there are `i rows` and `j columns`, the matrix is said to be an `“i by j” matrix, written “i× j.”` For example:

```verilog
⎡ 1   3   5 ⎤ 
⎢ 2   7   8 ⎥ 
⎢ 6   1   9 ⎥ 
⎣           ⎦ 
```

is a 3 × 3 matrix. A matrix with i rows and i columns is called `a square matrix of order i`. An ordinary number can be regarded as a 1 × 1 matrix; 
thus, 3 can be thought of as the matrix [ 3 ]. A matrix with only one row and n columns is called `a row vector`, and a matrix with only one column and i rows 
is called `a column vector`.

Matrices occur naturally in systems of simultaneous equations. In the following system for the unknowns x and y,

```
4 x  + 5 y = -2
-2 x - 6 y = 3 
```

the array of numbers

```verilog
⎡  4    5 ⎤ 
⎢ -2   -6 ⎥ 
⎣         ⎦ 
```

The multiplication of a matrix A by a matrix B to yield a matrix C is defined 
`only when the number of columns of the first matrix A equals the number of rows of the second matrix B.`

To determine the element C(ij), which is in the `i` th row and `j` th column of the product, the first element in the `i` th row of A is multiplied by the first element in the `j` th column of B, the second element in the row by the second element in the column, and so on until the last element in the row is multiplied by the last element of the column; 
the sum of all these products gives the element C(ij).
`The matrix C has as many rows as A and as many columns as B.`

In Verilog, declaring a matrix typically refers to defining a two-dimensional or multidimensional array, where each element may be a vector (packed) or an individual scalar (unpacked). This is commonly used to represent data structures like image buffers, lookup tables, or multi-channel data streams.

```verilog
reg [7:0] A1 [0:2][0:2];
```

3x3 matrix of 7-bit unsign registers

```verilog
A1 
[i] [j] 🡢
 🡣

⎡ A1[0][0]  A1[0][1]   A1[0][2] ⎤ 
⎢ A1[1][0]  A1[1][1]   A1[1][2] ⎥ 
⎢ A1[2][0]  A1[2][1]   A1[2][2] ⎥
⎣                               ⎦ 
```
In Verilog (or more precisely, SystemVerilog), you can declare a flat vector and then reinterpret or map it into a 3×3 matrix using unpacked arrays. This is useful when you receive a serialized input (e.g., a 1D bus) and want to work with it as a 2D structure.

```verilog
// Declare a flat 72-bit input vector (9 elements × 8 bits each)
logic [71:0] flat_data;

// Declare a 3×3 matrix of 8-bit elements
logic [7:0] matrix [0:2][0:2];

.....

always_comb begin
    // Row 0
    matrix[0][0] = flat_data[71:64];
    matrix[0][1] = flat_data[63:56];
    matrix[0][2] = flat_data[55:48];

    // Row 1
    matrix[1][0] = flat_data[47:40];
    matrix[1][1] = flat_data[39:32];
    matrix[1][2] = flat_data[31:24];

    // Row 2
    matrix[2][0] = flat_data[23:16];
    matrix[2][1] = flat_data[15:8];
    matrix[2][2] = flat_data[7:0];
end
```

