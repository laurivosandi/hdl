.. tags: VHDL, Verilog, IEEE1164, GHDL, D latch, KTH, IEEE1164
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

.. listing:: arithmetic/src/full_adder.vhd

VHDL Foreign Language Interface (FLI) allows architecture sections
to be written in languages other than VHDL, for example C.


Modelling styles
----------------

Sequential style follows closely software engineer point of view:

.. code:: vhdl

    -- XOR gate described using sequential style
    process(a,b)
    begin
        -- Not equals operator in VHDL is /=
        if (a/=b) then
            q <= '1';
        else
            q <= '0';
    end process;
        
Data flow style in this case is the most obvious:

.. code:: vhdl

    q <= a xor b;
    
Structural style maps closely to hardware, but in this case is pretty excessive:

.. code:: vhdl

    u1: inverter port map (a,ai);
    u2: inverter port map (b,bi);
    u3: and_gate port map (ai,b,t3);
    u4: and_gate port map (bi,a,t4);
    u5: or_gate port map (t3,t4,q);
    
Note that variables can be used only within process and no signals are
allowed in process declaration. Variable are not visible outside processes
and their assignments take effect immideately.
This essentially means the variable definitions have a scope,
in VHDL jargon it's known as name regions.
Signals on the other hand are declared in the architecutre header and they're 
shared among processes. During synthesis they essentially become wires.


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

Data types
----------

VHDL defines 6 built-in data types: bit, bit_vector, integer, real, time and
character:

.. code:: vhdl


    type boolean is (false, true);
    type bit is ('0', '1');
    type bit_vector is array(integer range <>) of bit;
    type character is (NUL, SOH,..., DEL);   -- 128 chars in VHDL'87
                                             -- 256 chars in VHDL'93
    type string is array(positive range <>) of character;

Subtype is a user constrained type derived from any of the built-in types.
Access types are essentially pointers, they can be used to dynamically
allocate storage.

Physical types can be constrained by user defined range.
Time units are only predefined type in VHDL.
Physical types have unit assocated with them:

.. code:: vhdl

    type resistance is range 0 to 1000000
    units
        ohm;
        Kohm = 1000 ohm;
        Mohm = 1000 kohm;
    end units;

IEEE predefined types:

.. code:: vhdl

    type std_ulogic is ('U', 'X', '0', '1', 'Z', 'W', 'L', 'H', '-');
    type std_logic is resolved std_ulogic; -- Resolution function call
    type std_logic_vector is array (integer range <>) of std_logic;

.. figure:: dia/vhdl-data-types.svg

    Data types in VHDL
    
    
Type attributes
---------------

Type attributes are defined for scalar types (real, integer, enumeration type) [#scalar-type-attributes]_:

.. code:: vhdl
    
    type color is (red, green, blue) -- Enumeration type
    color'left = red
    color'right = blue
    color'low = red
    color'high = blue
    color'ascending = true
    color'image(green) = "green"
    color'value("Red") = red
    
Type attributes for array types:

.. code:: vhdl

    subtype nibble is bit_vector(3 downto 0);
    nibble'range = 3 downto 0
    nibble'reversed_range = 0 to 3
    nibble'length = 4
    nibble'left = 3
    nibble'right = 0
    nibble'low = 0
    nibble'high = 3
    nibble'ascending = false
    nibble'element = bit

.. [#scalar-type-attributes] Designer's Guide to VHDL, page 55.


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
Note that sensitivity list is used for simulation, but it's
not used by synthesizer.

Signal attributes
-----------------

.. code::


Assertions
----------

Assertions can be used to validate code [#assert]_:

.. code:: vhdl

    assert initial_value >= min_value;
    
Report statement can be used to add verbosity:

.. code:: vhdl

    assert current_value >= min_value
        report "current value too low"

Severity level is defined as enumeration type:

.. code:: vhdl

    type severity_level is (note, warning, error, failure)

Level *failure* aborts the simulation.

.. code:: vhdl

    assert current_value >= min_value
        report "current value too low"
        severity failure;

.. [#assert] Designer's Guide to VHDL, page 87


VHDL simulation
---------------

.. figure:: dia/vhdl-simulation-cycle.svg

    

Delays in VHDL
--------------

VHDL distinguishes three delay models: inertial, transport and delta delay.

Delta delay is infinitesimal delay, meaning it can't be measured in units.
Delta delay essentially means that once process starts executing 
the signal assignments don't take effect until next simulation cycle.
Consider following code snippet: signal s is assigned value of 1, but
when *if* statement evaluates s, it still bears the value assigned to s from
previous cycle, not from current one [#delta]_.

.. code:: vhdl

    s <= '1'
    ...
    if s then ...

In real devices changing the output value involves moving electrons around and
that is affected by resistance, capacitance and inductance [#inertial]_.
To model such characteristics *inertial* keyword can be used.
Keyword *reject* can be used in conjucton with *inertial* to filter out
pulses within that time slot.
It essentially means that signal changes within certain timeframe
are not propagated. Using inertial delay gates can be described precisely:

.. code:: vhdl

    -- All three equivalent
    s0 <= s after 10 ns;
    s1 <= inertial s after 10 ns;
    s2 <= reject 10 ns inertial s after 10 ns;

Transport delay represents the lag of wiring within device.
It passes all input transitions with delay.
Keyword *transport*  can be used in such cases:

.. code:: vhdl

    s3 <= transport s after 10 ns;

Transport and intertial delays can't be synthesized in hardware,
it's the other way around - delays can be used to model actual hardware.

.. [#delta] Designer's Guide to VHDL, page 155
.. [#inertial] Designer's Guide to VHDL, page 158


Ports in VHDL
-------------

VHDL distinguishes three types of ports: in, out, inout.

For procedures:

* *signal* port modes may be *in*, *out*, *inout*. Last two have to be connected to a signal.
* *variable* mode may be *in*, *out*, *inout*. Last two have to be connected to a variable.
* *constant* may be only in *in* mode and connected to an expression which evaluates to constant within the procedure.


Packages
--------

Packages are used to collect: subprograms (functions, procedures),
data and type declarations and component declarations.
Entities and architectures can *not* be declared or defined in a pacakge.


Functions and procedures
------------------------

Functions produce a single return value and can not modify parameters
passed to it.

.. code:: vhdl

    function add_bits (a, b : in bit) return bit is
    begin
        return (a xor b);
    end add_bits;
    
Procedures don't require *return* statement and they can modify
signals declared as outputs.

.. code:: vhdl

    procedure add_bits3 (
        signal a, b, en : in bit;
        signal temp_result, temp_carry : out bit) is
    begin
        temp_result <= (a xor b) and en;
        temp_carry <= a and b and en;
    end add_bits3;
    
In a clocked body procedures can be invoked as follows:

.. code:: vhdl

    architecture behavior of adder is
    begin
        process (enable, x, y)
        begin
            add_bits3(x, y, enable, result, carry);
        end process;
    end behavior;
    
In concurrent statements it's slightly different:

.. code:: vhdl

    architecture behaviour of adder is
    begin
        u0: add_bits3 (a, b, en, temp_result, temp_carry);
    end example;


Aggregates
----------

Aggregate statement assigns several values simulatenously on the left-hand
side expession [#aggregate]:

.. code:: vhdl

    type point is array(1 to 3) of real;
    constant origin : point := (0.0, 0.0, 0.0);         -- Aggregate expression
    variable view_point : point := (10.0, 20.0, 0.0);   -- Another one

Aggregates also work the other way around:

.. code:: vhdl

    signal status_register : bit_vector(7 downto 0);
    signal interrupt_priority, cpu_priority : bit_vector(2 downto 0),
    signal interrupt_enable, cpu_mode : bit;
    
    ( 2 downto 0 => interrupt_priority,
      6 downto 4 => cpu_priority,
      3 => interrupt_enable,
      7 => cpu_mode) <= status_register;

Assigning structure values also constitutes as aggregate statement.

.. [#aggregate] Designer's Guide to VHDL, page 99

Bus resolution
--------------

IEEE1164 defined bus resolution via following constant:

.. code:: vhdl

    type std_logic_table is array(std_ulogic, std_ulogic) of std_ulogic;
    constant resolution_table : std_logic_table := (
        ('U', 'U', 'U', 'U', 'U', 'U', 'U', 'U', 'U'), -- U
        ('U', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X'), -- X
        ('U', 'X', '0', 'X', '0', '0', '0', '0', 'X'), -- 0
        ('U', 'X', 'X', '1', '1', '1', '1', '1', 'X'), -- 1
        ('U', 'X', '0', '1', 'Z', 'W', 'L', 'H', 'X'), -- Z
        ('U', 'X', '0', '1', 'W', 'W', 'W', 'W', 'X'), -- W
        ('U', 'X', '0', '1', 'L', 'W', 'L', 'W', 'X'), -- L
        ('U', 'X', '0', '1', 'H', 'W', 'W', 'H', 'X'), -- H
        ('U', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X'), -- -
    --    U    X    0    1    Z    W    L    H    -

The resolution table is used to determine what happens when two sources
drive same signal.
For example weak high and weak low result in weak drive:

.. code:: vhdl

    resolution_table('L', 'H') = 'W'
    
High and low result in X which symbolizes short-circuit:

.. code:: vhdl

    resolution_table('1', '0') = 'X'
    
Other tricks
------------

The *alias* statement can be used to refer to already defined identifiers [#alias]_
such as package items, record elements, array items and array slices:

.. code:: vhdl

    signal instruction   : bit_vector(15 downto 0);
    alias opcode         : bit_vector( 3 downto 0) is instruction(15 downto 12);
    alias src            : bit_vector( 1 downto 0) is instruction(11 downto 10);
    alias dest           : bit_vector( 1 downto 0) is instruction( 9 downto 8);
    alias immediate      : bit_vector( 7 downto 0) is instruction( 7 downto 0);

.. [#alias] Designer's Guide to VHDL, page 355
