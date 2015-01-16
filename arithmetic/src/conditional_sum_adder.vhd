library ieee;
use ieee.std_logic_1164.all;

entity conditonal_sum_adder is
    port (
        a : in  std_logic_vector (7 downto 0);
        b : in  std_logic_vector (7 downto 0);
        s : out std_logic_vector (7 downto 0));
end conditonal_sum_adder;

architecture behavioral of conditonal_sum_adder is

    -- Carries
    signal c0 : std_logic_vector(7 downto 0);
    signal c1 : std_logic_vector(7 downto 0);
    signal d0 : std_logic_vector(3 downto 0);
    signal d1 : std_logic_vector(3 downto 0);
    signal e0 : std_logic_vector(1 downto 0);
    signal e1 : std_logic_vector(1 downto 0);

    -- Sums
    signal s0 : std_logic_vector(7 downto 1);
    signal s1 : std_logic_vector(7 downto 1);
    signal t0 : std_logic_vector(7 downto 0);
    signal t1 : std_logic_vector(7 downto 0);
    signal u0 : std_logic_vector(4 downto 0);
    signal u1 : std_logic_vector(4 downto 0);
    signal v : std_logic_vector(4 downto 0);

begin
    -- Result generators
    s(0)  <= a(0) xor b(0);
    c0(0) <= a(0) and b(0);
    c1(0) <= c0(0);
    rg_loop: for i in 1 to 7 generate
        s0(i) <= a(i) xor b(i);
        s1(i) <= not s0(i);
        c0(i) <= a(i) and b(i);
        c1(i) <= a(i) or b(i);
    end generate;
    
    -- First stage carry selectors
    d1(3) <= (c1(6) and c1(7)) or (not c1(6) and c0(7));
    d0(3) <= (c0(6) and c1(7)) or (not c0(6) and c0(7));
    d1(2) <= (c1(4) and c1(5)) or (not c1(4) and c0(5));
    d0(2) <= (c0(4) and c1(5)) or (not c0(4) and c0(5));
    d1(1) <= (c1(2) and c1(3)) or (not c1(2) and c0(3));
    d0(1) <= (c0(2) and c1(3)) or (not c0(2) and c0(3));
    d1(0) <= (c1(0) and c1(1)) or (not c1(0) and c0(1));
    d0(0) <= (c0(0) and c1(1)) or (not c0(0) and c0(1));
    
    -- Second stage carry selectors
    e1(1) <= (d1(2) and d1(3)) or (not d1(2) and d0(3));
    e0(1) <= (d0(2) and d1(3)) or (not d0(2) and d0(3));
    e1(0) <= (d1(0) and d1(1)) or (not d1(0) and d0(1));
    e0(0) <= (d0(0) and d1(1)) or (not d0(0) and d0(1));
    
    -- First stage sum selectors
    t1(3) <= (c1(6) and s1(7)) or (not c1(6) and s0(7));
    t0(3) <= (c0(6) and s1(7)) or (not c0(6) and s0(7));
    t1(2) <= (c1(4) and s1(5)) or (not c1(4) and s0(5));
    t0(2) <= (c0(4) and s1(5)) or (not c0(4) and s0(5));
    t1(1) <= (c1(2) and s1(3)) or (not c1(2) and s0(3));
    t0(1) <= (c0(2) and s1(3)) or (not c0(2) and s0(3));
    t1(0) <= (c1(0) and s1(1)) or (not c1(0) and s0(1));
    s(1)  <= (c0(0) and s1(1)) or (not c0(0) and s0(1));
    
    -- Second stage sum selectors
    u1(3) <= (d1(2) and t1(3)) or (not d1(2) and t0(3));
    u0(3) <= (d0(2) and t1(3)) or (not d0(2) and t0(3));
    u1(2) <= (d1(2) and s1(6)) or (not d1(2) and s0(6));
    u0(2) <= (d0(2) and s1(6)) or (not d0(2) and s0(6));
    s(3)  <= (d0(0) and t1(1)) or (not d0(0) and t0(1));
    s(2)  <= (d0(0) and s1(2)) or (not d0(0) and s0(2));
    
    -- Third stage sum selectors
    s(7)  <= (e0(0) and u1(3)) or (not e0(0) and u0(3));
    s(6)  <= (e0(0) and u1(2)) or (not e0(0) and u0(2));
    s(5)  <= (e0(0) and t1(2)) or (not e0(0) and t0(2));
    s(4)  <= (e0(0) and s1(4)) or (not e0(0) and s0(4));
    
end behavioral;

