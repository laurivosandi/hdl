.. tags: VHDL, KTH, mux

Multiplexer
===========

Introduction
------------

Multiplexer or mux for short is essentially a switch.
The smallest possible mux has two inputs and one pin for selecting either of two.
There are various ways to implement such circuitry.

.. figure:: dia/mux-2-to-1-internals.svg

    2:1 mux composed of four NAND gates

High level block hides the internal gates.

.. figure:: dia/mux-2-to-1-example.svg

    2:1 mux symbol
    


Three 2:1 muxes can be combined to form 4:1 mux,
in that case one mux is selecting the output of either of two:

.. figure:: dia/mux-4-to-1-internals.svg

    4:1 mux composed of three 2:1 muxes

High level block for 4:1 hides the internal complexity.

.. figure:: dia/mux-4-to-1-example.svg

    4:1 multiplexer
    
Muxer can be described in VHDL using *case* statement in
sequential code, also known as clocked body.

.. listing:: src/mux.vhd

Muxer can be also described in VHDL using *with* *select* statement in
concurrent code:

.. code:: vhdl

    architecture behavioral of mux is
    begin
        with s select
            m <= a when "00",
            m <= b when "01",
            m <= c when "10",
            m <= d when others;
        end case;
    end behavioral;


