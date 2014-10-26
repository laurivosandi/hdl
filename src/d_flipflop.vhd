library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity d_flipflop is
    port (
        clk : in  std_logic;
        d   : in  std_logic;
        q   : out std_logic := '0');
end d_flipflop;

architecture behavioral of d_flipflop is
begin
    process(clk, d)
    begin
        -- attempting to use rising_edge with bit datatype gives
        -- d_flipflop.vhd:16:23: prefix is neither a function name nor can it be sliced or indexed
        if rising_edge(clk) then
            q<=d;
        end if;
    end process;
end behavioral;
