.. tags:  TU Berlin, computer arithmetic, Goldschmidt, division, VHDL
.. date: 2013-12-12

Goldschmidt division implementation
===================================

Introduction
------------

The `Goldschmidt division algorithm <goldschmidt-division-algorithm.html>`_
may seem straightforward, but the implementation might get quite complex.
In this case Goldschmidt divisor is composed of:

* Bit-vector based 4:2 counter
* Carry lookahead adder
* Reciprocal approximation circuit
* Radix-4 Booth encoder
* Booth encoder based multiplier
* Registers to hold intermediate N, D and F values
* Controller circuit which counts iterations
* Glue code

Adders and counters are not discussed in this article since they've been
covered in `various others <carry-look-ahead-adder.html>`_.

Booth encoder
-------------

The Booth encoder converts multiplier bit triplets into
addition and subtraction operations of multiplicand:

.. listing:: src/booth4.vhd


Booth encoder based multiplier
------------------------------

.. listing:: src/multiplier.vhd


Reciprocal approximator
-----------------------

The reciprocal approximator circuit determines approximate value
of the inverse of a number.

.. listing:: src/reciprocal.vhd


Glue code
---------

Goldschmidt division algorithm glues together all previously learned
components:

.. listing:: src/goldschmidt_division.vhd


Conclusion
----------

The main drawbacks of such simplistic design is that
the intermediate multiplication results are truncated and 
there is precision loss for every iteration.
In this case the division of 86 by 7 should result in number 
approximately 12.285714(285714), but after 4th iteration the precision loss
starts to affect the result and it deviates from that number:

.. code::

     8.062500000
    10.832031250
    12.140625000
    12.328125000
    12.375000000
    12.421875000
    12.468750000
    12.515625000
    12.562500000
    12.609375000
    12.656250000
    12.703125000
    12.750000000
    12.796875000
    12.843750000
    12.890625000
    12.937500000
    12.984375000
    13.031250000

On Xilinx Spartan 3E XC3S500E the latency of this circuit was 21.872ns which means
that we should be able to operate it on base frequency of:

.. math::

    \frac{1}{21.872ns} \approx 45.7MHz
    
The user of course has to take care of feeding
the correct number of iterations to the circuit and
delaying the output reading operation by that amount of cycles.
