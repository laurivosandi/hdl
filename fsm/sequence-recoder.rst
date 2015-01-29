.. tags: VHDL, KTH, Manchester

Sequence recoder
================

Introduction
------------

This is another example of FSM-s.

.. figure:: dia/sequence-recoder-specification.svg

    Sequence recoder specification, input sequence corresponding to output sequence.
    
Note that this is NFA (nondeterministic finite automaton) due to the fact
that there is no way to know where to go with only one lookahead symbol.

Mealy version
-------------

The outputs are scheduled as early as possible while avoiding conflicts.

.. figure:: dia/sequence-recoder-as-mealy.svg

    Sequence recoder as Mealy machine

Next step is to label states.

.. figure:: dia/sequence-recoder-as-mealy-labeled.svg

    Sequence recoder as Mealy machine
    
Corresponding flow table:

+-----------+-------------+-------------+
| State tag | Next state  | Output      |
|           +------+------+------+------+
|           | I=0  | I=1  | I=0  | I=1  |
+-----------+------+------+------+------+
| S0        | S1   | S6   | –    | –    |
+-----------+------+------+------+------+
| S1        | S4   | S2   | 0    | 1    |
+-----------+------+------+------+------+
| S2        | S3   | S3   | 0    | 0    |
+-----------+------+------+------+------+
| S3        | S0   | S0   | –    | –    |
+-----------+------+------+------+------+
| S4        | S5   | S5   | 0    | 0    |
+-----------+------+------+------+------+
| S5        | S0   | S0   | –    | –    |
+-----------+------+------+------+------+
| S6        | S9   | S7   | 0    | 1    |
+-----------+------+------+------+------+
| S7        | S8   | S8   | 1    | 1    |
+-----------+------+------+------+------+
| S8        | S0   | S0   | –    | –    |
+-----------+------+------+------+------+
| S9        | S10  | S10  | 1    | 1    |
+-----------+------+------+------+------+
| S10       | S0   | S0   | –    | –    |
+-----------+------+------+------+------+

Next step is to substitute don't care outputs for example with zeros.
All output combinations that are the same belong to the same class.
Classes that have the same future are equivalent.
Thus S3, S5, S8 and S10 can be merged.
Subsequently S7 an be merged with S9 and
S2 with S4.

+-----------+-------------+-------------+
| State tag | Next state  | Output      |
|           +------+------+------+------+
|           | I=0  | I=1  | I=0  | I=1  |
+-----------+------+------+------+------+
| E0        | E1   | E6   | –    | –    |
+-----------+------+------+------+------+
| E1        | E2   | E2   | 0    | 1    |
+-----------+------+------+------+------+
| E2        | E3   | E3   | 0    | 0    |
+-----------+------+------+------+------+
| E3        | E0   | E0   | –    | –    |
+-----------+------+------+------+------+
| E6        | E7   | E7   | 0    | 1    |
+-----------+------+------+------+------+
| E7        | E3   | E3   | 1    | 1    |
+-----------+------+------+------+------+

.. figure:: dia/sequence-recoder-as-mealy-labeled-minimized.svg

    Minimized state diagram
    

State encoding
--------------

There are many possible ways to encode states in logic:

+-----------------+-----------------+-----------------+-----------------+
| State tag       | Binary encoding | Gray encoding   | One-hot         |
+-----------------+-----------------+-----------------+-----------------+
| E0              | 00              | 00              | 0001            |
+-----------------+-----------------+-----------------+-----------------+
| E1              | 01              | 01              | 0010            |
+-----------------+-----------------+-----------------+-----------------+
| E2              | 10              | 11              | 0100            |
+-----------------+-----------------+-----------------+-----------------+
| E3              | 11              | 10              | 1000            |
+-----------------+-----------------+-----------------+-----------------+

Binary encoding yields total hamming distance of 10:

.. figure:: dia/manchester-decoder-as-mealy-binary-hamming-distance.svg

    Hamming distances of transitions using binary encoding.
    
Binary encoding yields total hamming distance of 8:

.. figure:: dia/manchester-decoder-as-mealy-gray-hamming-distance.svg

    Hamming distances of transitions using Gray encoding.
    
Hamming distances using one-hot encoding yields total distance of 14:

.. figure:: dia/manchester-decoder-as-mealy-one-hot-hamming-distance.svg

    Hamming distances of transitions using one-hot encoding.




