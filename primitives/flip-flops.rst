.. tags: flip-flop, latch, VHDL, D latch, SR latch, KTH, critical path

Flip-flops
==========

Introduction
------------

Flip-flop is edge-triggered, opaque, clocked, synchronous, edge-sensitive
opposed to latch which is simple, transparent, not clocked, asynchronous, level-sensitive.

A flip-flop can be constructed from two D latches.
Clear distinction is made between rising edge and falling edge triggered
flip flops.

.. figure:: dia/flipflop-falling-edge-internals.svg

    Falling edge triggered flip-flop constructed with two D latches.

.. figure:: dia/flipflop-rising-edge-internals.svg

    Rising edge triggered flip-flop constructed with two D latches.


Risinge edge triggered flip-flop described using VHDL.
    
.. listing:: src/d_flipflop.vhd

.. figure:: dia/d-register-symbol-explained.svg

    D register symbol
    
Critical path
-------------

Introducing flip-flops to a circuit makes critical path calculation more complex.
At least four cases are distinguished:

* From input to output if no flip-flops are involved.
* Circuit iput to flip-flop input.
* Flip-flop output to circuit output.
* Flip-flop output to flip-flop input within the circuit or to another circuit.

FIFO-s
------

Flip-flops can be used to construct a synchronous FIFO:

.. figure:: dia/serial-to-parallel-converter.svg

Such FIFO can be modeled using VHDL.

.. code:: vhdl

    process(clk)
    begin
        if (clk='1') and clk'event then
            q(7 downto 0)<= d & q(7 downto 1);
        end if;
    end process;
    
Timing analysis
---------------

There are no feedbacks in flip-flop assuming that flip-flop is composed of
two D latches, thus delay elements don't have to be introduced to the circuit.

.. figure:: dia/flipflop-falling-edge-timing.svg

Expressions for the next state:

.. math:: r = clk \cdot d + \overline{clk} \cdot r_{previous}
.. math:: q = \overline{clk} \cdot r + clk \cdot q_{previous}
       
.. comment:: r =     clk and  d or not clk and rp
.. comment:: q = not clk and rp or     clk and qp

Excitation table:

+---------------+---------------------------+
| Present state | Next state (clk,d)        |
| (rp,qp)       +------+------+------+------+
|               |  00  |  01  |  10  |  11  |
|               +------+------+------+------+
|               | Next state (r,q)          |
+---------------+------+------+------+------+
| 00            |**00**|**00**|**00**|  10  |
+---------------+------+------+------+------+
| 01            |  00  |  00  |**01**|  11  |
+---------------+------+------+------+------+
| 10            |  11  |  11  |  00  |**10**|
+---------------+------+------+------+------+
| 11            |**11**|**11**|  01  |**11**|
+---------------+------+------+------+------+

Stable states marked in bold are the ones where next state is equal to
present state.



