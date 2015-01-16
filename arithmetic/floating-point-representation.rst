.. title: Floating-point multiplication
.. tags:  TU Berlin, computer arithmetic, multiplication, floating-point, IEEE754
.. date: 2013-11-28

Floating-point multiplication
=============================

Introduction
------------

In computers real numbers are represented in floating point format.
Usually this means that the number is split into *exponent* and *fraction*,
which is also known as *significand* or *mantissa*:

.. math::

    real\:number \rightarrow mantissa \times base ^ {exponent}

The mantissa is within the range of 0 .. base.
Usually 2 is used as base, this means that mantissa has to be within 0 .. 2.
In case of normalized numbers the mantissa is within range 1 .. 2 to take
full advantage of the precision this format offers.

For instance Pi can be rewritten as follows:

.. math::

    3.1415927 = 1.5707963705062866 \times 2 ^ 1


Single-precision floating point numbers
---------------------------------------

Most modern computers use IEEE 754 standard to represent floating-point
numbers. One of the most commonly used format is the *binary32*
format of IEEE 754:

.. code::

   sign                    fraction/significand/mantissa (23 bits)
    |                      /                                     \
    |  exponent (8 bits)  /                                       \
    |   /           \    /                                         \
    0  1 0 0 0 0 0 0 0  1 0 0 1 0 0 1 0 0 0 0 1 1 1 1 1 1 0 1 1 0 1 1

Note that exponent is encoded using an offset-binary representation,
which means it's always off by 127. So if usually
10000000 in binary would be 128 in decimal, in single-precision
the value of exponent is:

.. math::

    exponent = 128 - offset = 128 - 127 = 1
    
Same goes for fraction bits, if usually 
10010010000111111011011 in binary would evaluate to 4788187 in decimal then
in case of single-precision numbers their weights are shifted and off by one:

.. math::

    mantissa = 4788187 \times 2 ^ {-23} + 1 = 1.5707963705062866


Multiplication of single-precision numbers
------------------------------------------

Multiplication of such numbers can be tricky.
In this example let's use numbers:

.. math::

    a = 6.96875
    
.. math::

    b = -0.3418
    
Normalized values and biased exponents:

.. math::

    a = 6.96875 = 1.7421875 \times 2 ^ 2
    
.. math::

    b = -0.3418 = -1.3672 \times 2 ^ {-2}
    
The exponents:

.. math::

    exponent_a = 2

.. math::

    exponent_b = -2

The numbers in IEEE754 *binary32*:

.. math::

    a = 0 10000001 10111110000000000000000_{binary32}

.. math::

    b = 1 01111101 01011110000000001101001_{binary32}

    
The mantissa could be rewritten as following totaling 24 bits per operand:

.. math::

    mantissa_a = 1.10111110000000000000000_2
    
.. math::

    mantissa_b = 1.01011110000000001101001_2
    
Their multiplication totals in 48 bits:

.. math::

    mantissa_{a \times b} = 1.00110000111000101011011011101110000000000000000_2
    
Which has to be truncated to 24 bits:

.. math::

    mantissa_{a \times b} = 1.00110000111000101011011_2 = 2.3819186687469482421875_{10}
    
The exponents 2 and -2 can easily be summed up so only last thing to
do is to normalize fraction which means that the resulting number is:

.. math::

    a \times b = -2.3819186687469482421875 = -1.19095933437347412109375 \times 2 ^ 1
    
Which could be written in IEEE 754 *binary32* format as:

.. math::

    a \times b = 0 10000000 00110000111000101011011_{binary32}


Multiplication of double-precision numbers
------------------------------------------

The IEEE 754 standard also specifies 64-bit representation of floating-point
numbers called *binary64* also known as double-precision floating-point number.

.. code::

   sign              fraction aka significand aka mantissa (52 bits)
    |                 /                                          \
    |  exponent      /                                            \
    |  (11 bits)    /                                              \
    |  /       \   /                                                \    
    0 10000000000 1001001000011111101101010100010001000010110100011000
    
Compared to *binary32* representation 3 bits are added for exponent and 29 for mantissa:

.. code::


    0 10000000000 1001001000011111101101010100010001000010110100011000
    0 10000000    10010010000111111011011

Thus pi can be rewritten with higher precision:

.. math::

    3.14159265358979311599796346854 = 1.57079632679489655799898173427 \times 2 ^ 1
    
The multiplication with earlier presented numbers:

.. math::

    a = 6.96875 = 1.7421875 \times 2 ^ 2
    
.. math::

    b = -0.3418 = -1.3672 \times 2 ^ {-2}

Yields in following *binary64* representation:

.. math::

    a = 0 10000000001 1011111000000000000000000000000000000000000000000000_{binary64}
    
.. math::

    b = 1 01111111101 0101111000000000110100011011011100010111010110001110_{binary64}

Thu fraction operands are 53 bits each:

.. math::

    mantissa_a = 1.1011111000000000000000000000000000000000000000000000_2
    
.. math::

    mantissa_b = 1.0101111000000000110100011011011100010111010110001110_2
    
And their multiplication is 106 bits long:
    
.. math::

    mantissa_{a \times b} = 1.001100001110001010110110101011100111110101010110011010110010(0)_2
    
Which of course means that it has to be truncated to 53 bits:

.. math::

    mantissa_{a \times b} \approx 1.0011000011100010101101101010111001111101010101100110_2
    
The exponent is handled as in single-precision arithmetic, thus the resulting number in *binary64* format is:

.. math::

    a \times b = 0 10000000000 0011000011100010101101101010111001111101010101100110_{binary64}
    
Which converted to decimal is:

.. math::

    a \times b = -2.38191874999999964046537570539


Conclusion
----------

Expected result:

.. math::

    -2.38191875

Single-precision result:

.. math::

    -2.3819186687469482421875
    
Double-precision result:

.. math::

    -2.38191874999999964046537570539
    
As can be seen single-precision arithmetic distorts the result around
6th fraction digit whereas double-precision arithmetic result diverges
around 15th fraction digit.

