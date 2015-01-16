.. tags: GHDL, VHDL, GCC, KTH
.. date: 2014-10-16

Full adder
==========

Full adder is essentially composed of two half adders.

.. figure:: dia/full-adder.svg

    Full adder constructed using two XOR, two OR and one AND gate
    
Full adder can be described in VHDL:

.. listing:: src/full_adder.vhd

Full adder can also be implemented using two 4:1 muxes:

.. figure:: dia/full-adder-muxes.svg

    Full adder using two 4:1 muxes
    


