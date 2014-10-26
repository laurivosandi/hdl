library ieee;
use ieee.std_logic_1164.all;

entity d_testbench is end d_testbench;

architecture behavioral of d_testbench is
    component d_Latch
        port (
            clk : in  std_logic;
            d   : in  std_logic;
            q   : out std_logic
        );
    end component;
    component d_flipflop
        port (
            clk : in  std_logic;
            d   : in  std_logic;
            q   : out std_logic
        );
    end component;
    signal input, clk, output_latch, output_flipflop : std_logic := '0';
begin
    input <= 
        '0',
        '1' after 15 ns,
        '0' after 65 ns,
        '1' after 70 ns,
        '0' after 75 ns,
        '1' after 125 ns;
    clk<=
        '0',
        '1' after 20 NS,
        '0' after 40 NS,
        '1' after 60 ns,
        '0' after 80 ns,
        '1' after 100 ns,
        '0' after 120 ns;
    uut1: d_latch port map(input, clk, output_latch);
    uut2: d_flipflop port map(input, clk, output_flipflop);

END behavioral;
