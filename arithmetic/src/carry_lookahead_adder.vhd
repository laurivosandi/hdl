library ieee;
use ieee.std_logic_1164.all;

-- 15-bit carry look-ahead adder
entity carry_lookahead_adder is
    port (
        a  : in  std_logic_vector (14 downto 0);
        b  : in  std_logic_vector (14 downto 0);
        ci : in  std_logic;
        s  : out std_logic_vector (14 downto 0);
        co : out std_logic
    );
end carry_lookahead_adder;

architecture behavioral of carry_lookahead_adder is
    signal t : std_logic_vector(14 DOWNTO 0);
    signal g : std_logic_vector(14 DOWNTO 0);
    signal p : std_logic_vector(14 DOWNTO 0);
    signal c : std_logic_vector(14 DOWNTO 1);
begin
    -- Product stage    
    g <= a and b;
    p <= a or b;
    
    -- Sum stage
    t <= a xor b;
    
    -- Carry stage
    c(1) <= g(0) or (p(0) and ci);
    carry_loop: for i in 1 to 13 generate
        c(i+1) <= g(i) or (p(i) and c(i));
    end generate;
    
    co <= g(14) or (p(14) and c(14));
    s(0) <= t(0) xor ci;
    s(14 downto 1) <= t(14 downto 1) xor c(14 downto 1);
end behavioral;
