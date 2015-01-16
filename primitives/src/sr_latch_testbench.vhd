library ieee;
use ieee.std_logic_1164.all;

entity sr_latch_testbench is end sr_latch_testbench;

architecture behavioral of sr_latch_testbench IS
    component sr_latch
        port (
            s     : in    std_logic;
            r     : in    std_logic;
            q_n   : inout std_logic;
            q     : inout std_logic);
    end component;
    signal q, q_n : std_logic := '0';
    signal input  : std_logic_vector(1 downto 0);
begin
    input <=
        -- a,b
        "10",
        "11" AFTER 5 ns,
        "01" AFTER 10 ns,
        "11" AFTER 15 ns,
        "10" AFTER 20 ns,
        "11" AFTER 25 ns,
        "00" AFTER 30 ns;
    uut: sr_latch port map (input(1), input(0), q_n, q);
end behavioral;
