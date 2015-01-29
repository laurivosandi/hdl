----------------------------------------------------------------------------------
-- Engineer: Mike Field <hamster@snap.net.nz>
-- 
-- Description: Convert the push button to a 1PPS that can be used to restart
--              camera initialisation
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity debounce is
    port (
        clk : in  std_logic;
        i   : in  std_logic;
        o   : out std_logic
    );
end debounce;

architecture behavioral of debounce is
	signal c : unsigned(23 downto 0);
begin
	process(clk)
	begin
        if rising_edge(clk) then
            if i = '1' then
                if c = x"ffffff" then
                    o <= '1';
                else
                    o <= '0';
                end if;
                c <= c+1;
            else
                c <= (others => '0');
                o <= '0';
            end if;
        end if;
	end process;
end behavioral;


