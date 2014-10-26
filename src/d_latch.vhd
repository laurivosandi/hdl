library ieee;
use ieee.std_logic_1164.all;

entity d_latch is
    port (
        clk : in  std_logic;
        d   : in  std_logic;
        q   : out std_logic);
end d_latch;

architecture behavioural of d_latch is
begin
    process(d, clk)
    begin
        if (clk = '1') then
            q <= d;
        end if;
    end process;
end behavioural;

