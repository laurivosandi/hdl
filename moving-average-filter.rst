.. title: Moving average filter
.. tags:  TU Berlin, computer arithmetic, VHDL, conditional sum adder, adder
.. date: 2013-12-18

Moving average filter
=====================

Introduction
------------

In this assignment we'll attempt to improve design of a moving average filter.
The circuit accepts 16 signed 11-bit fixed point numbers as input and produces
the average of those numbers, which is also signed 11-bit fixed point number.
In this case we are using 4:2 carry-save adders and one carry-lookahead adder,
this means that we have to compute the sums in several stages:

1. Sign-extension
2. 16 inputs to 8 sums using 4x CSA-s
3. 8 sums to 4 sums using 2x CSA-s
4. 4 sums to 2 sums using 1x CSA-s
5. Final sum using CLA
6. Divide by 16

The last step, division by 16 is implemented by proper wiring.
Division by power of 2 can simply be replaced with bit shift.


Show the design with sign extension
-----------------------------------

Assuming that input format is a signed 11-bit fixed point number
with following sign bit, integer bit and fraction bit distribution:

.. code::

    4  3  2  1  0 -1 -2 -3 -4 -5 -6
    S  I  I  I  I  F  F  F  F  F  F

Each carry-preserving CSA step adds one bit to the output.
That could result in 15-bit number for the final sum.
This means that we have to prepend 4-bits to each input
with their corresponding sign bits:

.. code::


    14 13 12 11 10 9  8  7  6  5  4  3  2  1  0 (i)
    
    E  E  E  E  S  •  •  •  •  •  •  •  •  •  •
    E  E  E  E  S  •  •  •  •  •  •  •  •  •  •
    E  E  E  E  S  •  •  •  •  •  •  •  •  •  •
    E  E  E  E  S  •  •  •  •  •  •  •  •  •  •
    
    E  E  E  E  S  •  •  •  •  •  •  •  •  •  •
    E  E  E  E  S  •  •  •  •  •  •  •  •  •  •
    E  E  E  E  S  •  •  •  •  •  •  •  •  •  •
    E  E  E  E  S  •  •  •  •  •  •  •  •  •  •

    E  E  E  E  S  •  •  •  •  •  •  •  •  •  •
    E  E  E  E  S  •  •  •  •  •  •  •  •  •  •
    E  E  E  E  S  •  •  •  •  •  •  •  •  •  •
    E  E  E  E  S  •  •  •  •  •  •  •  •  •  •

    E  E  E  E  S  •  •  •  •  •  •  •  •  •  •
    E  E  E  E  S  •  •  •  •  •  •  •  •  •  •
    E  E  E  E  S  •  •  •  •  •  •  •  •  •  •
    E  E  E  E  S  •  •  •  •  •  •  •  •  •  •
    -------------------------------------------
    S  •  •  •  •  •  •  •  •  •  •  •  •  •  •

Each sign extension could be represented as:

.. math::

    E_k = S_k \cdot \sum_{i=11}^{14} 2^i
    
Knowing that we don't care about the overflowing carry bit we
can rewrite that formula as:

.. math::

    E_k = \bar{S_k} \cdot 2^{11} + \sum_{i=11}^{14} 2^i
    
In expaneded form:

.. math::

    E_k = \bar{S_k} \cdot 2^{11} + 2^{11} + 2^{12} + 2^{13} + 2^{14}
    
Sum of 16 sign extensions yields:

.. math::

    E = \sum_{k=1}^{16} (\bar{S_k} \cdot 2^{11}) + 16 \times (2^{11} + 2^{12} + 2^{13} + 2^{14})
    
Multiplication by 16 can be substituted by shifting bits left by 4:

.. math::

    E = \sum_{k=1}^{16} (\bar{S_k} \cdot 2^{11}) + 2^{15} + 2^{16} + 2^{17} + 2^{18}
    
Knowing that we don't care about bits on positions higher than 14, we
can omit them:

.. math::

    E = \sum_{k=1}^{16} (\bar{S_k} \cdot 2^{11})
    
Thus we can rewrite our initial operands as following:

.. code::

       14 13 12 11 10  9  8  7  6  5  4  3  2  1  0 (i)

                !S  S  •  •  •  •  •  •  •  •  •  •
                !S  S  •  •  •  •  •  •  •  •  •  •
                !S  S  •  •  •  •  •  •  •  •  •  •
                !S  S  •  •  •  •  •  •  •  •  •  •
        
                !S  S  •  •  •  •  •  •  •  •  •  •
                !S  S  •  •  •  •  •  •  •  •  •  •
                !S  S  •  •  •  •  •  •  •  •  •  •
                !S  S  •  •  •  •  •  •  •  •  •  •
        
                !S  S  •  •  •  •  •  •  •  •  •  •
                !S  S  •  •  •  •  •  •  •  •  •  •
                !S  S  •  •  •  •  •  •  •  •  •  •
                !S  S  •  •  •  •  •  •  •  •  •  •
        
                !S  S  •  •  •  •  •  •  •  •  •  •
                !S  S  •  •  •  •  •  •  •  •  •  •
                !S  S  •  •  •  •  •  •  •  •  •  •
                !S  S  •  •  •  •  •  •  •  •  •  •
    -----------------------------------------------
        S  •  •  •  •  •  •  •  •  •  •  •  •  •  •


Calculate minimum period for the clock using the proposed architecture
----------------------------------------------------------------------

Latencies are assumed as followed:

* Sign-extension is of one NAND gate: 2Δ 
* CSA: 4Δ
* CLA: 8Δ
* Division by 16: 0Δ

This results total delay of:

.. math::

    2Δ + 3 \times 4Δ + 8Δ = 22Δ


How to reduce this period?
--------------------------

Possible options include:

* Overclocking of course
* Tradeoff between area and latency, replace CSA's with something faster
* Completely redesign the circuit

The last bullet point means that we get rid of the whole addition circuitry
and just use one 2-operand adder and subtractor plus a register to hold
previously calculated sum.


Implementation with 4:2 counters and CLA
----------------------------------------

We use 4:2 counter that works on bit vectors:

.. listing:: src/counter42.vhd

The compact carry lookahead adder:

.. listing:: src/carry_lookahead_adder.vhd

The VHDL code which binds the 4:2 counters and CLA together:

.. listing:: src/moving_average_filter.vhd

Clock to pad latencies with 4:2 counter and CLA approach on
Xilinx Spartan 3E XC5500E:

.. code::

    ------------+------------+------------------+--------+
                | clk (edge) |                  | Clock  |
    Destination |   to PAD   |Internal Clock(s) | Phase  |
    ------------+------------+------------------+--------+
    sout<0>     |   18.045(R)|clk_BUFGP         |   0.000|
    sout<1>     |   19.570(R)|clk_BUFGP         |   0.000|
    sout<2>     |   22.070(R)|clk_BUFGP         |   0.000|
    sout<3>     |   22.590(R)|clk_BUFGP         |   0.000|
    sout<4>     |   23.284(R)|clk_BUFGP         |   0.000|
    sout<5>     |   23.491(R)|clk_BUFGP         |   0.000|
    sout<6>     |   25.868(R)|clk_BUFGP         |   0.000|
    sout<7>     |   26.537(R)|clk_BUFGP         |   0.000|
    sout<8>     |   28.455(R)|clk_BUFGP         |   0.000|
    sout<9>     |   28.867(R)|clk_BUFGP         |   0.000|
    sout<10>    |   29.660(R)|clk_BUFGP         |   0.000|
    ------------+------------+------------------+--------+

    
Show the complete circuit for the new design
--------------------------------------------

The period of following circuit is of two CLA-s and delays caused by the registers.
It should be roughly twice faster than previous design and should consume
also less area:

.. figure:: img/moving-average-filter-modified.png

    Modified moving average filter


The implementation of new design
--------------------------------

The improved design uses same carry lookahead adder but discards the 
4:2 counters:

.. listing:: src/moving_average_filter_improved.vhd


Clock to pad latencies for Xilinx Spartan 3E XC5500E:

.. code::

    Clock clk to Pad
    ------------+------------+------------------+--------+
                | clk (edge) |                  | Clock  |
    Destination |   to PAD   |Internal Clock(s) | Phase  |
    ------------+------------+------------------+--------+
    sout<0>     |   12.472(R)|clk_BUFGP         |   0.000|
    sout<1>     |   13.126(R)|clk_BUFGP         |   0.000|
    sout<2>     |   13.671(R)|clk_BUFGP         |   0.000|
    sout<3>     |   13.694(R)|clk_BUFGP         |   0.000|
    sout<4>     |   14.166(R)|clk_BUFGP         |   0.000|
    sout<5>     |   14.511(R)|clk_BUFGP         |   0.000|
    sout<6>     |   14.705(R)|clk_BUFGP         |   0.000|
    sout<7>     |   15.152(R)|clk_BUFGP         |   0.000|
    sout<8>     |   15.132(R)|clk_BUFGP         |   0.000|
    sout<9>     |   14.369(R)|clk_BUFGP         |   0.000|
    sout<10>    |   14.614(R)|clk_BUFGP         |   0.000|
    ------------+------------+------------------+--------+


Analysis of the designs
-----------------------

The latency of 4:2 counter + CLA design is 29.66ns, which is
three times better than the initial goal:

.. math::

    \frac{1}{29.66ns} \approx 34MHz
    
The latency of adder-subtractor design has double the performance of
previous design and it is nearly 7 times better than the initial goal:

.. math::

    \frac{1}{14.614} \approx 68MHz
    
Adding a register to buffer the output would allow rising the frequency even
higher, this would of course mean that the output would be delayed by one cycle.


Waveforms
---------

The signal fed to the circuit:

.. math::

    S(t) = 10 cos ( 2 \Pi t \times \frac {10}{1000}) + sin(2 \Pi t \times \frac{100}{1000})

Yields in following charts for input and output:

.. chart:: Line
    :human_readable: False
    :fill: False
    :style: LightStyle
    :show_dots: False
    :show_legend: False

    'Input', [10.5625, 10.859375, 10.765625, 10.265625, 9.5, 8.703125, 8.09375, 7.796875, 7.84375, 8.078125, 8.28125, 8.234375, 7.78125, 6.953125, 5.875, 4.765625, 3.859375, 3.296875, 3.078125, 3.078125, 3.0625, 2.8125, 2.203125, 1.203125, 0.0, -1.203125, -2.203125, -2.8125, -3.0625, -3.078125, -3.078125, -3.296875, -3.859375, -4.765625, -5.875, -6.953125, -7.78125, -8.234375, -8.28125, -8.078125, -7.84375, -7.796875, -8.09375, -8.703125, -9.5, -10.265625, -10.765625, -10.859375, -10.5625, -10.0, -9.390625, -8.96875, -8.859375, -9.09375, -9.5, -9.875, -9.984375, -9.703125, -9.015625, -8.078125, -7.109375, -6.328125, -5.890625, -5.78125, -5.875, -5.9375, -5.765625, -5.203125, -4.265625, -3.078125, -1.890625, -0.921875, -0.296875, -0.03125, 0.0, 0.03125, 0.296875, 0.921875, 1.890625, 3.078125, 4.265625, 5.203125, 5.765625, 5.9375, 5.875, 5.78125, 5.890625, 6.328125, 7.109375, 8.078125, 9.015625, 9.703125, 9.984375, 9.875, 9.5, 9.09375, 8.859375, 8.96875, 9.390625, 10.0, 10.5625, 10.859375, 10.765625, 10.265625, 9.5, 8.703125, 8.09375, 7.796875, 7.84375, 8.078125, 8.28125, 8.234375, 7.78125, 6.953125, 5.875, 4.765625, 3.859375, 3.296875, 3.078125, 3.078125, 3.0625, 2.8125, 2.203125, 1.203125, 0.0, -1.203125, -2.203125, -2.8125, -3.0625, -3.078125, -3.078125, -3.296875, -3.859375, -4.765625, -5.875, -6.953125, -7.78125, -8.234375, -8.28125, -8.078125, -7.84375, -7.796875, -8.09375, -8.703125, -9.5, -10.265625, -10.765625, -10.859375, -10.5625, -10.0, -9.390625, -8.96875, -8.859375, -9.09375, -9.5, -9.875, -9.984375, -9.703125, -9.015625, -8.078125, -7.109375, -6.328125, -5.890625, -5.78125, -5.875, -5.9375, -5.765625, -5.203125, -4.265625, -3.078125, -1.890625, -0.921875, -0.296875, -0.03125, 0.0, 0.03125, 0.296875, 0.921875, 1.890625, 3.078125, 4.265625]
    'Output', [0.0, 0.65625, 1.328125, 2.0, 2.640625, 3.234375, 3.78125, 4.28125, 4.765625, 5.265625, 5.765625, 6.28125, 6.796875, 7.28125, 7.71875, 8.078125, 8.375, 7.96875, 7.484375, 7.015625, 6.5625, 6.15625, 5.78125, 5.421875, 5.0, 4.515625, 3.9375, 3.28125, 2.59375, 1.90625, 1.28125, 0.71875, 0.21875, -0.265625, -0.765625, -1.328125, -1.953125, -2.625, -3.328125, -3.984375, -4.5625, -5.046875, -5.46875, -5.828125, -6.203125, -6.609375, -7.046875, -7.53125, -8.0, -8.421875, -8.75, -8.96875, -9.09375, -9.171875, -9.21875, -9.296875, -9.40625, -9.546875, -9.65625, -9.71875, -9.6875, -9.53125, -9.28125, -8.984375, -8.65625, -8.375, -8.109375, -7.890625, -7.65625, -7.375, -7.0, -6.515625, -5.953125, -5.359375, -4.75, -4.1875, -3.6875, -3.21875, -2.765625, -2.28125, -1.734375, -1.09375, -0.40625, 0.3125, 1.015625, 1.640625, 2.203125, 2.6875, 3.140625, 3.609375, 4.109375, 4.671875, 5.28125, 5.875, 6.4375, 6.90625, 7.28125, 7.578125, 7.8125, 8.03125, 8.296875, 8.578125, 8.90625, 9.203125, 9.453125, 9.609375, 9.640625, 9.578125, 9.46875, 9.328125, 9.21875, 9.140625, 9.09375, 9.015625, 8.890625, 8.671875, 8.34375, 7.921875, 7.453125, 6.96875, 6.515625, 6.125, 5.75, 5.390625, 4.96875, 4.484375, 3.890625, 3.25, 2.546875, 1.875, 1.25, 0.6875, 0.1875, -0.296875, -0.796875, -1.359375, -1.984375, -2.671875, -3.359375, -4.015625, -4.59375, -5.078125, -5.5, -5.875, -6.234375, -6.640625, -7.09375, -7.5625, -8.046875, -8.46875, -8.796875, -9.015625, -9.140625, -9.203125, -9.25, -9.328125, -9.4375, -9.578125, -9.703125, -9.75, -9.71875, -9.5625, -9.328125, -9.015625, -8.703125, -8.40625, -8.15625, -7.921875, -7.6875, -7.40625, -7.03125, -6.546875, -6.0, -5.390625, -4.78125, -4.21875, -3.71875, -3.25, -2.796875, -2.3125, -1.765625]

