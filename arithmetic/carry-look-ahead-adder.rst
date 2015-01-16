.. tags:  TU Berlin, Computer Arithmetic, VHDL, adder, carry look-ahead adder
.. date: 2013-11-27

Carry look-ahead adder
======================

Carry lookahead adder is composed of three stages:

.. code:: vhdl

    library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;

    entity CarryLookaheadAdder is
        Port ( a : in  STD_LOGIC_VECTOR (7 downto 0);
               b : in  STD_LOGIC_VECTOR (7 downto 0);
               ci : in  STD_LOGIC;
               s : out  STD_LOGIC_VECTOR (7 downto 0);
               co : out  STD_LOGIC);
    end CarryLookaheadAdder;

    architecture Behavioral of CarryLookaheadAdder is

    signal g:STD_LOGIC_VECTOR (7 downto 0);
    signal p:STD_LOGIC_VECTOR (7 downto 0);
    signal c:STD_LOGIC_VECTOR (7 downto 0);

    begin
        product_loop: for i in 0 to 7 generate
            p(i) <= a(i) xor b(i);
            g(i) <= a(i) and b(i);
            
        end generate;
        
        s(0) <= p(0) xor ci;
        sum_loop: for i in 0 to 6 generate
            s(i+1) <= p(i+1) xor c(i);
        end generate;

        c(0) <=
            g(0) or
            (ci and p(0));

        c(1) <=
            g(1) or
            (g(0) and p(1)) or
            (ci and p(1) and p(0));

        c(2) <=
            g(2) or 
            (g(1) and p(2)) or
            (g(0) and p(2) and p(1)) or
            (ci and p(2) and p(1) and p(0));

        c(3) <=
            g(3) or
            (g(2) and p(3)) or
            (g(1) and p(3) and p(2)) or
            (g(0) and p(3) and p(2) and p(1)) or
            (ci and p(3) and p(2) and p(1) and p(0));
            
        c(4) <=
            g(4) or
            (g(3) and p(4)) or
            (g(2) and p(4) and p(3)) or
            (g(1) and p(4) and p(3) and p(2)) or
            (g(0) and p(4) and p(3) and p(2) and p(1)) or
            (ci and p(4) and p(3) and p(2) and p(1) and p(0));
            

        c(5) <=
            g(5) or
            (g(4) and p(5)) or
            (g(3) and p(5) and p(4)) or
            (g(2) and p(5) and p(4) and p(3)) or
            (g(1) and p(5) and p(4) and p(3) and p(2)) or
            (g(0) and p(5) and p(4) and p(3) and p(2) and p(1)) or
            (ci and p(5) and p(4) and p(3) and p(2) and p(1) and p(0));

        c(6) <=
            g(6) or
            (g(5) and p(6)) or 
            (g(4) and p(6) and p(5)) or
            (g(3) and p(6) and p(5) and p(4)) or
            (g(2) and p(6) and p(5) and p(4) and p(3)) or
            (g(1) and p(6) and p(5) and p(4) and p(3) and p(2)) or
            (g(0) and p(6) and p(5) and p(4) and p(3) and p(2) and p(1)) or
            (ci and p(6) and p(5) and p(4) and p(3) and p(2) and p(1) and p(0));


        c(7) <=
            g(7) or
            (g(6) and p(7)) or
            (g(5) and p(7) and p(6)) or 
            (g(4) and p(7) and p(6) and p(5)) or
            (g(3) and p(7) and p(6) and p(5) and p(4)) or
            (g(2) and p(7) and p(6) and p(5) and p(4) and p(3)) or
            (g(1) and p(7) and p(6) and p(5) and p(4) and p(3) and p(2)) or
            (g(0) and p(7) and p(6) and p(5) and p(4) and p(3) and p(2) and p(1)) or
            (ci and p(7) and p(6) and p(5) and p(4) and p(3) and p(2) and p(1) and p(0));


    end Behavioral;

Metrics for Xilinx Spartan 3E XC3S500E:

* Latency of critical path: 11.735ns
* Number of inputs: 17 (2x 8-bit operands plus carry in)
* Number of outputs: 8 (8-bit sum)
* Number of 4-input LUTs: 15
  
Conculsion: Carry lookahead adder should perform better, but it seems that it
heavily depends on the underlying implementation. For instance what happens
with compound AND statements? X and Y and Z could in theory be implemented with
one multiple-input AND gate, but seeing the latencies grow across outputs
makes me believe that compound AND statements translate into
cascaded 2-input (N)AND gates:

.. code::

    Pad to Pad 
    ---------------+---------------+---------+ 
    Source Pad     |Destination Pad|  Delay  | 
    ---------------+---------------+---------+ 
    a<0>           |s<0>           |    6.192| 
    a<0>           |s<1>           |    6.470| 
    a<0>           |s<2>           |    7.915| 
    a<0>           |s<3>           |    9.267| 
    a<0>           |s<4>           |    9.539| 
    a<0>           |s<5>           |   10.518| 
    a<0>           |s<6>           |   11.594| 
    a<0>           |s<7>           |   11.692| 
    a<1>           |s<1>           |    6.553| 
    a<1>           |s<2>           |    6.916| 
    a<1>           |s<3>           |    8.268| 
    a<1>           |s<4>           |    8.540| 
    a<1>           |s<5>           |    9.519| 
    a<1>           |s<6>           |   10.595| 
    a<1>           |s<7>           |   10.693| 
    a<2>           |s<2>           |    6.026| 
    a<2>           |s<3>           |    7.496| 
    a<2>           |s<4>           |    7.768| 
    a<2>           |s<5>           |    8.747| 
    a<2>           |s<6>           |    9.823| 
    a<2>           |s<7>           |    9.921| 
    a<3>           |s<3>           |    7.012| 
    a<3>           |s<4>           |    6.807| 
    a<3>           |s<5>           |    7.786| 
    a<3>           |s<6>           |    8.862| 
    a<3>           |s<7>           |    8.960| 
    a<4>           |s<4>           |    6.085| 
    a<4>           |s<5>           |    7.030| 
    a<4>           |s<6>           |    8.106| 
    a<4>           |s<7>           |    8.204| 
    a<5>           |s<5>           |    5.725| 
    a<5>           |s<6>           |    6.445| 
    a<5>           |s<7>           |    6.543| 
    a<6>           |s<6>           |    6.202| 
    a<6>           |s<7>           |    6.488| 
    a<7>           |s<7>           |    6.202| 
    b<0>           |s<0>           |    5.823| 
    b<0>           |s<1>           |    6.139| 
    b<0>           |s<2>           |    7.584| 
    b<0>           |s<3>           |    8.936| 
    b<0>           |s<4>           |    9.208| 
    b<0>           |s<5>           |   10.187| 
    b<0>           |s<6>           |   11.263| 
    b<0>           |s<7>           |   11.361| 
    b<1>           |s<1>           |    5.760| 
    b<1>           |s<2>           |    6.771| 
    b<1>           |s<3>           |    8.123| 
    b<1>           |s<4>           |    8.395| 
    b<1>           |s<5>           |    9.374| 
    b<1>           |s<6>           |   10.450| 
    b<1>           |s<7>           |   10.548| 
    b<2>           |s<2>           |    5.940| 
    b<2>           |s<3>           |    7.437| 
    b<2>           |s<4>           |    7.709| 
    b<2>           |s<5>           |    8.688| 
    b<2>           |s<6>           |    9.764| 
    b<2>           |s<7>           |    9.862| 
    b<3>           |s<3>           |    6.043| 
    b<3>           |s<4>           |    6.322| 
    b<3>           |s<5>           |    7.301| 
    b<3>           |s<6>           |    8.377| 
    b<3>           |s<7>           |    8.475| 
    b<4>           |s<4>           |    5.997| 
    b<4>           |s<5>           |    6.971| 
    b<4>           |s<6>           |    8.047| 
    b<4>           |s<7>           |    8.145| 
    b<5>           |s<5>           |    5.593| 
    b<5>           |s<6>           |    6.665| 
    b<5>           |s<7>           |    6.763| 
    b<6>           |s<6>           |    5.651| 
    b<6>           |s<7>           |    6.447| 
    b<7>           |s<7>           |    5.890| 
    ci             |s<0>           |    6.054| 
    ci             |s<1>           |    6.513| 
    ci             |s<2>           |    7.958| 
    ci             |s<3>           |    9.310| 
    ci             |s<4>           |    9.582| 
    ci             |s<5>           |   10.561| 
    ci             |s<6>           |   11.637| 
    ci             |s<7>           |   11.735| 
    ---------------+---------------+---------+ 
