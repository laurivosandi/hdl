.. tags: VHDL, Verilog, IEEE1164, GHDL, D latch, KTH
.. date: 2014-10-13

HDL basics
==========

Introduction
------------

Hardware description languages (HDL) are used to describe electronical circuits.
The two main flavours of hardware description languages are VHDL and Verilog.
VHDL was initially defined in 1980 by United States Department of Defence
and it has long history of behing closely tied to military, integrated circuit
industry and academic circles.
There are not so many open-source VHDL simulators available,
but `GHDL <ghdl.html>`_ seems to be the most usable at the moment.


VHDL
----

VHDL splits hardware description to *entity* and *architecture*
similarily to Java with splits method declaration to *interface* and *implementation*.
The *entity* is used to describe how an digital logic component package looks like:
how many ports there are whether they can be used as inputs, outputs or both.
The *architecture* on the other hand describes what's happening on the inside,
thus defining the behavioral logic:

.. listing:: src/full_adder.vhd


Inference rules
---------------

Most programming languages are naturally sequential, while threads and 
event loops are used to add concurrency.
VHDL as actual hardware on the other hand is concurrent by default, for instance in the
code snippet above the two output assignment operations are carried out in parallel.
VHDL also permits defining sequential processes.
Following chart describes what approximately happens during synthesis of VHDL code:

.. code:: vhdl

.. figure:: dia/inference-rules.svg

    Relationship between synthesis and VHDL code


Sequential processes
--------------------

The *process* keyword is used to describe sequential or also known as clocked code.
For instance following code snippet becomes D latch with asynchronous reset:

.. code:: vhdl

    process(d, reset, clk)
    begin
        if (reset = '0') then
            q <= '0';
        elsif (clk = '1') then
            q <= d;
        end if;
    end process;

In this case *d*, *reset* and *clk* are signals in the *sensitivity list* of the process.
The process is entered with any change to the signals in the *sensitivity list*.


