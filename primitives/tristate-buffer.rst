.. tags: VHDL, KTH, tristate

Tristate buffer
===============

.. figure:: dia/tristate-buffer.svg

    Tristate buffer with active high control

Tristate buffer can be described in VHDL using logic state 'Z' which
refers to high impediance state.

.. listing:: src/tristate_buffer.vhd
