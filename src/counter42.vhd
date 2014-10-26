library ieee;
use ieee.std_logic_1164.all;

-- 15-bit 4:2 counter

entity counter42 is
    port ( a : in  STD_LOGIC_VECTOR (14 downto 0);
           b : in  STD_LOGIC_VECTOR (14 downto 0);
           c : in  STD_LOGIC_VECTOR (14 downto 0);
           d : in  STD_LOGIC_VECTOR (14 downto 0);
           s : out  STD_LOGIC_VECTOR (14 downto 0);
           co : out  STD_LOGIC_VECTOR (14 downto 0));
end counter42;

architecture behavioral of counter42 is

signal si : STD_LOGIC_VECTOR (14 downto 0);
signal ti : STD_LOGIC_VECTOR (15 downto 0);

begin

    ti(0) <= '0';
    counter_loop: for j in 0 to 14 generate
        -- First 3:2 counter
        si(j) <=  c(j) xor b(j) xor a(j);
        ti(j+1) <= (c(j) and b(j)) or ((b(j) xor c(j)) and a(j));
        
        -- Second 3:2 counter
        s(j) <= si(j) xor d(j) xor ti(j);
        co(j) <= (si(j) and d(j)) or ((si(j) xor d(j)) and ti(j));

    end generate;

end behavioral;
