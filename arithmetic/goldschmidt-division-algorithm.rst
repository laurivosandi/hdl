.. tags:  TU Berlin, computer arithmetic, Goldschmidt, division
.. date: 2013-12-05

Goldschmidt division algorithm
==============================

Introduction
------------

Goldschmidt division is iterative division algorithm
deployed in many processors.
Higher precision can be achieved by adding fraction bits
for intermediate calculations or by having more iterations.

Given
-----

Dividend:

.. math::

  N_{-1} = 86_{10} = 01010110.000000000000_{2}

Divisor:

.. math::

  D_{-1} = 7_{10} = 00000111.000000000000_{2}

Correct result:

.. math::

  Q = \frac{N_{-1}}{D_{-1}} = 12.285714285714285714285714285714285714285714285714

Initial reciprocal is the inverse of divisor which is calculated by
shifting bits around the fraction point:

.. math::

  F_{-1} = \frac{1}{D_{-1}} \approx 0.0546875_{10} = 00000000.000011100000_{2}

In this case we have 8 bits for integers and 12 bits
for fraction digits.

Algorithm steps
---------------

Iteration #1:

.. math::

  N_{0} = F_{-1} \times N_{-1} = 4.703125_{10} = 00000100.101101000000_{2}

.. math::

  D_{0} = F_{-1} \times D_{-1} = 0.3828125_{10} = 00000000.011000100000_{2}

.. math::

  F_{0} = 2 - D_{0} = 1.6171875_{10} = 00000001.100111100000_{2}

Iteration #2:

.. math::

  N_{1} = F_{0} \times N_{0} = 7.605712890625_{10} = 00000111.100110110001_{2}

.. math::

  D_{1} = F_{0} \times D_{0} = 0.618896484375_{10} = 00000000.100111100111_{2}

.. math::

  F_{1} = 2 - D_{1} = 1.381103515625_{10} = 00000001.011000011001_{2}

Iteration #3:

.. math::

  N_{2} = F_{1} \times N_{1} = 10.504150390625_{10} = 00001010.100000010001_{2}

.. math::

  D_{2} = F_{1} \times D_{1} = 0.854736328125_{10} = 00000000.110110101101_{2}

.. math::

  F_{2} = 2 - D_{2} = 1.145263671875_{10} = 00000001.001001010011_{2}

Iteration #4:

.. math::

  N_{3} = F_{2} \times N_{2} = 12.02978515625_{10} = 00001100.000001111010_{2}

.. math::

  D_{3} = F_{2} \times D_{2} = 0.978759765625_{10} = 00000000.111110101001_{2}

.. math::

  F_{3} = 2 - D_{3} = 1.021240234375_{10} = 00000001.000001010111_{2}

Iteration #5:

.. math::

  N_{4} = F_{3} \times N_{3} = 12.28515625_{10} = 00001100.010010010000_{2}

.. math::

  D_{4} = F_{3} \times D_{3} = 0.99951171875_{10} = 00000000.111111111110_{2}

.. math::

  F_{4} = 2 - D_{4} = 1.00048828125_{10} = 00000001.000000000010_{2}

Conclusion
----------

The result after 5 iterations is:

.. math::

    N_{5} = 12.28515625_{10} = 00001100.010010010000_{2}

Which deviates from the correct result by:

.. math::

     100\% - |\frac{N_5}{Q}| = 0.0045 \%

