.. tags: GHDL, VHDL, GCC, KTH
.. date: 2014-10-16

Using GHDL to simulate VHDL
===========================

Introduction
------------

Open-source tools for VHDL seem to be lacking, I am mainly using GHDL [#ghdl]_ to
analyze and simulate VHDL design.
Verilog on the other hand has a lot of open-source tools available [#icarus]_ [#verilator]_.
Note that VHDL is case insensitive, at least for modern compilers.
Personally I think it's nice to have your code yelling at you therefore
I default to lowercase. Consistency throughout any software project is 
of course the most important aspect.


Installing GHDL
---------------

I have used packages built by Joris van Rantwijk to install GHDL on my Debian Wheezy machine [#ghdl_debian]_.
These instructions should be double-checked for any other distribution of course:

.. code:: bash

    wget http://sourceforge.net/projects/ghdl-updates/files/Builds/ghdl-0.31/Debian/ghdl_0.31-2wheezy1_amd64.deb
    sudo dpkg -i ghdl_0.31-2wheezy1_amd64.deb


Analyzing design
----------------

I think it's a good convention to keep the entity name synchronized with the filename and also in lower case.
GHDL also seems to look up components by the filename.
So for example following entity should be saved to **full_adder.vhd**:

.. listing:: src/full_adder.vhd

To compile binary object **full_adder.o** from a VHDL source file **full_adder.vhd** use the -a analyze command-line option:

.. code:: bash

    ghdl -a full_adder.vhd

Now these object files can be referred by other entities via component declaration.

Elaborating design
------------------

Consider following testbench source code in file **full_adder_testbench.vhd**:

.. listing:: src/full_adder_testbench.vhd

The object file for testbench must be compiled aswell:

.. code:: bash

    ghdl -a full_adder_testbench.vhd

Running GHDL with the elaborate option -e will produce a binary and link all the related entities to the binary.
Note that object file **full_adder_testbench.o** here is referred by the entity name **full_adder_testbench**:

.. code:: bash

    ghdl -a full_adder_testbench

Now you have binary ready to go:

.. code:: bash

    ./full_adder_testbench

Which should output:

.. code::

    full_adder_testbench.vhd:36:9:@70ns:(report note): Full adder testbench finished

Putting it all together
-----------------------

Makefiles help out tracing changes to modified files:

.. listing:: src/Makefile

Place the file as **Makefile** next to VHDL files.
In this case issuing simply *make* in that directory would compile all necessary files and execute testbenches.

.. [#ghdl] https://gna.org/projects/ghdl/
.. [#icarus] http://iverilog.icarus.com/
.. [#verilator] http://www.veripool.org/wiki/verilator
.. [#ghdl_debian] http://jorisvr.nl/ghdl_debian.html

