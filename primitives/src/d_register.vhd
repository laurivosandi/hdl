library ieee;
use ieee.std_logic_1164.all;

entity d_register is
    port (
        clk : in    std_logic;
        d   : in    std_logic;
        q   : out   std_logic);
end d_register;

architecture behave of d_register is
begin
    process(clk, d)
    begin
        if clk'event and clk = '1' then
            q <= d;
        end if;
    end process;
end behave;
