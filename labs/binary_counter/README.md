# **Binary Counter Using LEDs**

We have 8 LEDs, and we want to implement a counter on them. Each time one of the 8 bits is set to 1, one LED will light up. The clock frequency is 50 MHz, which means 50 million cycles per second. In binary terms, this equals log2(50e6) = 26 bits.
 
```$clog2 (CLK * 1000*1000)```                                                                                                                           

Our counter will increment by one each clock cycle, and we need to allocate only 8 bits for our counter. We use :

```cnt[$left (cnt-:led)```                                                                                                                                       

to extract the [25:18] slice from the 26-bit counter, assigning it to our LEDs.

We specifically chose the most significant 8 bits of our counter because the clock frequency is very high for the human eye, and we wouldn’t be able to see the LEDs turn on and off if we used the least significant bits. The changes would happen too fast: 00000000, 00000001, 00000010, 00000011, and so on. The ones would change very quickly, so we need a delay between when the LEDs turn off and on.

Therefore, while the 17 least significant bits change, it will take 2^17 = 131072 cycles for the first bit of the 8 control LED bits to change, and the same interval will be between each change of the 8 control bits. In this way, we can control the speed of the LEDs. If we increase the interval, the LEDs will light up slower; if we reduce the interval, the LEDs will light up faster.

```00000000 XXXXXXXXXXXXXXXXXX``` – the most significant bits control the LEDs, and the least significant bits introduce the delay.

### The example I described above is just for simplicity and understanding.

## Four bit counter

![4 bit binary counter](bnr_cntr.gif)

SW0 is responsible for the reset (rst), and it is in the logic low state. As seen at a frequency of 100 MHz, the switching frequency of the LEDs is still quite fast, so I left only 4 LEDs to make it more convenient to observe the counter. It is also possible to reduce the frequency and limit the number of active LEDs to visually track the counter. This can be done in this line of code by modifying the parameters:

```cnt[$left (cnt-:led)```