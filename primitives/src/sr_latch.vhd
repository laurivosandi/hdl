library ieee;
use ieee.std_logic_1164.all;

entity sr_latch is
    port (
        s   : in    std_logic;
        r   : in    std_logic;
        q   : inout std_logic;
        q_n : inout std_logic);
end sr_latch;

architecture behavioral of sr_latch is
begin
    q   <= r nand q_n;
    q_n <= s nand q;
end behavioral;
