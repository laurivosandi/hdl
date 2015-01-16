.. tags:  TU Berlin, Computer Arithmetic, VHDL, adder, full adder, carry ripple adder
.. date: 2013-11-27

Carry ripple adder
==================

Full adder
----------

A full adder calculates the sum of three inputs:

.. listing:: src/full_adder.vhd
    
Using gates:

.. figure:: dia/full-adder.svg

    Full adder schematic using two XOR, two AND and one OR gate.
    

Carry ripple adder
------------------

Carry ripple adder is composed of full adders:

.. listing:: src/carry_ripple_adder.vhd
    
Metrics for Xilinx Spartan 3E XC35500E:

* Latency of critical path: 9.131ns
* Number of inputs: 17 (2x 8-bit operands plus carry in)
* Number of outputs: 8 (8-bit sum)
* Number of 4-input LUTs: 15

The critical path is as excpected between the input carry (*ci*)
and most significant bit of output (*s<7>*):

.. code::

    Pad to Pad 
    ---------------+---------------+---------+ 
    Source Pad     |Destination Pad|  Delay  | 
    ---------------+---------------+---------+ 
    a<0>           |s<0>           |    4.830| 
    a<0>           |s<1>           |    5.542| 
    a<0>           |s<2>           |    6.254| 
    a<0>           |s<3>           |    6.966| 
    a<0>           |s<4>           |    7.678| 
    a<0>           |s<5>           |    8.390| 
    a<0>           |s<6>           |    9.102| 
    a<0>           |s<7>           |    9.131| 
    a<1>           |s<1>           |    4.830| 
    a<1>           |s<2>           |    5.542| 
    a<1>           |s<3>           |    6.254| 
    a<1>           |s<4>           |    6.966| 
    a<1>           |s<5>           |    7.678| 
    a<1>           |s<6>           |    8.390| 
    a<1>           |s<7>           |    8.419| 
    a<2>           |s<2>           |    4.830| 
    a<2>           |s<3>           |    5.542| 
    a<2>           |s<4>           |    6.254| 
    a<2>           |s<5>           |    6.966| 
    a<2>           |s<6>           |    7.678| 
    a<2>           |s<7>           |    7.707| 
    a<3>           |s<3>           |    4.830| 
    a<3>           |s<4>           |    5.542| 
    a<3>           |s<5>           |    6.254| 
    a<3>           |s<6>           |    6.966| 
    a<3>           |s<7>           |    6.995| 
    a<4>           |s<4>           |    4.830| 
    a<4>           |s<5>           |    5.542| 
    a<4>           |s<6>           |    6.254| 
    a<4>           |s<7>           |    6.283| 
    a<5>           |s<5>           |    4.830| 
    a<5>           |s<6>           |    5.542| 
    a<5>           |s<7>           |    5.571| 
    a<6>           |s<6>           |    4.830| 
    a<6>           |s<7>           |    5.108| 
    a<7>           |s<7>           |    5.108| 
    b<0>           |s<0>           |    4.830| 
    b<0>           |s<1>           |    5.542| 
    b<0>           |s<2>           |    6.254| 
    b<0>           |s<3>           |    6.966| 
    b<0>           |s<4>           |    7.678| 
    b<0>           |s<5>           |    8.390| 
    b<0>           |s<6>           |    9.102| 
    b<0>           |s<7>           |    9.131| 
    b<1>           |s<1>           |    4.830| 
    b<1>           |s<2>           |    5.542| 
    b<1>           |s<3>           |    6.254| 
    b<1>           |s<4>           |    6.966| 
    b<1>           |s<5>           |    7.678| 
    b<1>           |s<6>           |    8.390| 
    b<1>           |s<7>           |    8.419| 
    b<2>           |s<2>           |    4.830| 
    b<2>           |s<3>           |    5.542| 
    b<2>           |s<4>           |    6.254| 
    b<2>           |s<5>           |    6.966| 
    b<2>           |s<6>           |    7.678| 
    b<2>           |s<7>           |    7.707| 
    b<3>           |s<3>           |    4.830| 
    b<3>           |s<4>           |    5.542| 
    b<3>           |s<5>           |    6.254| 
    b<3>           |s<6>           |    6.966| 
    b<3>           |s<7>           |    6.995| 
    b<4>           |s<4>           |    4.830| 
    b<4>           |s<5>           |    5.542| 
    b<4>           |s<6>           |    6.254| 
    b<4>           |s<7>           |    6.283| 
    b<5>           |s<5>           |    4.830| 
    b<5>           |s<6>           |    5.542| 
    b<5>           |s<7>           |    5.571| 
    b<6>           |s<6>           |    4.830| 
    b<6>           |s<7>           |    5.108| 
    b<7>           |s<7>           |    5.108| 
    ci             |s<0>           |    4.830| 
    ci             |s<1>           |    5.542| 
    ci             |s<2>           |    6.254| 
    ci             |s<3>           |    6.966| 
    ci             |s<4>           |    7.678| 
    ci             |s<5>           |    8.390| 
    ci             |s<6>           |    9.102| 
    ci             |s<7>           |    9.131| 
    ---------------+---------------+---------+ 

