## The critical path

The critical path is the longest segment of combinational logic, and it determines the clock frequency.
## Pipelining

What to do if the critical path is too long?
The simplest approach is to break it up by inserting registers within segments of combinational logic. This is the fundamental principle of pipelining.
Pipelining is the process of dividing a computational task into separate stages, each executed in a single clock cycle. Once a stage is completed, the data is passed to the next stage, allowing the first stage to begin processing a new set of data.
As a result, the maximum delay is reduced, allowing for a higher clock frequency.
However, latency increases—meaning the output result takes multiple clock cycles to appear.

## Pipeline Filling

Initially, as data enters the pipeline, the first output corresponds to the first input, similar to how water flows through a pipe.

## Key Feature of Pipelining

A crucial characteristic of pipelining is that it carries input values along with it for a certain number of clock cycles.
Example: Automotive Assembly Line
Without pipelining: Constantly returning to fetch the initial input values, which slows down the process.
With pipelining: The input values travel through the pipeline for three clock cycles, eliminating the need to hold them at the initial trigger.

Instead of keeping the input occupied, a new value X can be fed in every clock cycle, allowing continuous computation without delays.
In a pipelined architecture, new data can be fed into the input every clock cycle without waiting for the computations of the previous value to complete.

## Pipeline Concept for Exponentiation

Problem Statement
We want to compute the cube of a number 
𝑋
X, i.e.,

𝑌
=
𝑋
3
=
𝑋
×
𝑋
×
𝑋
Y=X 
3
 =X×X×X
Using pipelining, we break this computation into multiple stages to allow continuous processing of new input values, maximizing throughput.

Concept of Pipelining
In pipelining, a task is divided into smaller stages, each performing part of the computation. The result from each stage is passed on to the next stage, and multiple tasks can be processed simultaneously at different stages of the pipeline. Here's how it works for exponentiation:

Stage 1: Compute 
𝑆1 = 𝑋 × 𝑋

Stage 2: Compute 
𝑆2 = 𝑆1 × 𝑋

Stage 3: Output the result 
𝑌 = 𝑆2

Each of these stages is executed in parallel during different clock cycles, allowing a new input value to be processed each cycle.

## Example Scenario: Calculating Cube of Multiple Numbers

For instance, let's assume you need to compute the cube of three numbers:

- \( X_1 = 2 \)
- \( X_2 = 3 \)
- \( X_3 = 4 \)

Here’s how the pipeline would work over several clock cycles:

| Clock Cycle | Stage 1 (X²)  | Stage 2 (X³) | Output (Y) |
|-------------|---------------|--------------|------------|
| **1**       | \( X_1^2 = 4 \)  | -            | -          |
| **2**       | \( X_2^2 = 9 \)  | \( X_1^3 = 8 \) | -          |
| **3**       | \( X_3^2 = 16 \) | \( X_2^3 = 27 \) | \( Y_1 = 8 \) |
| **4**       | -               | \( X_3^3 = 64 \) | \( Y_2 = 27 \) |
| **5**       | -               | -            | \( Y_3 = 64 \) |

Each clock cycle processes a new number, while intermediate results are propagated through the pipeline.




