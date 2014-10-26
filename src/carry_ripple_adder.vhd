library ieee;
use ieee.std_logic_1164.all;

entity carry_ripple_adder is
    generic (
        WIDTH : integer := 8
    );
    port (
        a  : in  std_logic_vector (WIDTH-1 downto 0);
        b  : in  std_logic_vector (WIDTH-1 downto 0);
        ci : in  std_logic;
        s  : out std_logic_vector (WIDTH-1 downto 0);
        co : out  std_logic
    );
end;

architecture behavioral of carry_ripple_adder is
    signal c: std_logic_vector (WIDTH downto 0);
begin
    s(0) <= a(0) xor b(0) xor ci;
    c(0) <= (a(0) and b(0)) or ((a(0) xor b(0)) and ci);
    my_loop: for i in 1 to WIDTH-1 generate
        s(i) <= a(i) xor b(i) xor c(i-1);
        c(i) <= (a(i) and b(i)) or ((a(i) xor b(i)) and c(i-1));
    end generate;
    co <= c(WIDTH-1);
end Behavioral;

