# *MATRIX*

Matrix, a set of numbers arranged in rows and columns so as to form a rectangular array. The numbers are called the elements, or entries, of the matrix.
If there are `i rows` and `j columns`, the matrix is said to be an `“i by j” matrix, written “i× j.”` For example:

``` ⎡ 1   3   5 ⎤ ```
``` ⎢ 2   7   8 ⎥ ```
``` ⎢ 6   1   9 ⎥ ```
``` ⎣           ⎦ ```

is a 3 × 3 matrix. A matrix with i rows and i columns is called `a square matrix of order i`. An ordinary number can be regarded as a 1 × 1 matrix; 
thus, 3 can be thought of as the matrix [ 3 ]. A matrix with only one row and n columns is called `a row vector`, and a matrix with only one column and i rows 
is called `a column vector`.

Matrices occur naturally in systems of simultaneous equations. In the following system for the unknowns x and y,

```  4x + 5y = -2 ```
``` -2x - 6y = 3  ```

the array of numbers

``` ⎡  4    5 ⎤ ```
``` ⎢ -2   -6 ⎥ ```
``` ⎣         ⎦ ```

The multiplication of a matrix A by a matrix B to yield a matrix C is defined 
`only when the number of columns of the first matrix A equals the number of rows of the second matrix B.`

To determine the element C(ij), which is in the `i` th row and `j` th column of the product, the first element in the `i` th row of A is multiplied by the first element in the `j` th column of B, the second element in the row by the second element in the column, and so on until the last element in the row is multiplied by the last element of the column; 
the sum of all these products gives the element C(ij).
`The matrix C has as many rows as A and as many columns as B.`

In Verilog, declaring a matrix typically refers to defining a two-dimensional or multidimensional array, where each element may be a vector (packed) or an individual scalar (unpacked). This is commonly used to represent data structures like image buffers, lookup tables, or multi-channel data streams.

```verilog
reg [15:0] A1 [0:2][0:2];
```

