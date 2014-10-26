.. tags:  TU Berlin, computer arithmetic, decimal, binary, hexadecimal, octal, radix, Python, baseconvert
.. date: 2014-01-16

Numbering systems
=================

From decimal to binary
----------------------

People have become so accustomed with decimal system that we can't imagine
any other way to count numbers.
Decimal system is actually one of many numeral systems that does not make
much sense to a computer.
On the lowest level computers count numbers in binary,
of course for a human reading binary numbers in efficient and error-prone.

In binary each digit has weight of power of two.
Simply put the rightmost digit has weight of 2 to the power of 0,
the next one to the left has weight of 2 to the power of 1,
the next 2 to the power of 2 and so forth.

This is also known as radix-2 or base 2 numeral system which basically
means that for earch digit there are 2 values.
Usually this means 1 and 0 but true and false, high and low, on and off
may be used aswell. It really depends on the interpretation.

From binary to octal and hexadecimal
------------------------------------

Computer engineers figured that by grouping bits the numbers become more readable.
Grouping bits by two would not do much good as the digit value would be from 0 to 3.
In octal numbering system each digit has decimal value from 0 to 7.
In binary this corresponds to 000 .. 111.
Reading triplets such as this breaks the computing pattern of power of 2's.
So the next logical step was to add another bit, in that case 6 new digits were
added to cover all possible combinations of four bits:

.. code::

    binary    hexadecimal    decimal
    0000   => 0           => 0
    0001   => 1           => 1
    0010   => 2           => 2
    0011   => 3           => 3

    0100   => 4           => 4
    0101   => 5           => 5
    0110   => 6           => 6
    0111   => 7           => 7

    1000   => 8           => 8
    1001   => 9           => 9
    1010   => A           => 10
    1011   => B           => 11

    1100   => C           => 12
    1101   => D           => 13
    1110   => E           => 14
    1111   => F           => 15
    
Obviously the question is what happens if we add 1 to the F in hexadecimal?
Basically the same thing when you add 1 to 9 in decimal,
current digit is reset and the one with higher weight is increased by one,
thus 1 + F = 10 and 1 + 1F = 20 in hexadecimal.

Octal numbering is also known radix-8 or base 8 and
hexadecimal is known as radix-16 or base 16.
Hexadecimal also points out that the digits are just symbols
to denote digits value between zero or lack of value and the base.

The presented numbering systems are actually special cases of those radix numbering systems,
first of all it is assumed the weights are growing from right to left
and that digits are not signed.
The wellknown decimal system is radix-10 or base 10,
however we could write the digits as -4 -3 -2 -1 0 1 2 3 4 5 and still call it a radix-10 numbering system.

Number notations in programming languages
-----------------------------------------

Most programming languages (C, Python, PHP, etc) allow you to **assign** **integers** in various
notations. Python shell allows easy conversion of mentioned numbering systems:

.. code:: python

   a = 0xff         # Hexadecimal numbers are prefixed with 0x
   b = 123          # Decimal numbers are written as-is
   c = 0777         # Octal numbers are prefixed with 0
   d = 0b11111111   # Binary numbers are prefixed with 0b

By default integers are **displayed** in decimal regardless
of notation it was entered because the numerical
value does not depend on it's representation:

.. code:: python

    a   # Returns 255
    b   # Returns 123
    c   # Returns 511
    d   # Returns 255

Of course assigning variables in not neccessary:

.. code:: python

    0xfffe   # Returns 65534
    12345    # Returns 12345
    0755     # Returns 493
    0b10     # Returns 2

These last two lines should now help to understand what it means 
"There are only 10 types of people in the world: Those who understand binary, and those who don't".

To get the value's representation in different numerical systems there are helper functions like bin, oct and hex to get the **string**:

.. code:: python

    hex(255)   # Returns '0xff'
    oct(255)   # Returns '0377'
    bin(255)   # Returns '0b11111111'

You may also use printf syntax:

.. code:: python

    x = 24672
    "Padded hexadecimal value of %d is %08x" % (x, x)   # Returns 'Padded hexadecimal value of 24672 is 00006060'
