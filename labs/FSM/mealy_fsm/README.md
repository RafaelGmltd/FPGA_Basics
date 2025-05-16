# *Mealy machine*

In this case the graph represents a Mealy machine because its outputs are associated
with the state transitions (edges). The nomenclature 00/0 is quite usual and means that, when
the inputs are 00 (the two bits before the “/”) the output is 0 (the bit after the “/”). So, this
graph shows the behavior of a 2-input, 1-output sequential system

![Mealy FSM](Mealy_fsm.jpg)

**0 -> 1 -> 2 -> 3 -> 0**

The output value changes before the state because the output value is assigned through continuous 
assignment, which reacts to any change in the input data, while the state reacts only to the clock signal

![Mealy FSM](mealy.gif)
