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
        -- Detect rising edge
        if clk'event and clk = '1' then
            q <= d;
        end if;
    end process;
end behavioral;
