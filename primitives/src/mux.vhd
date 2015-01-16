library ieee;
use ieee.std_logic_1164.all;

entity mux is
    port (
        a : in  std_logic;
        b : in  std_logic;
        c : in  std_logic;
        d : in  std_logic;
        s : in  std_logic_vector(1 downto 0);
        m : out std_logic);
end mux;

architecture behavioral of mux is
begin
    process(a,b,c,d,s) begin
        case s is
            when "00"   => m <= a;
            when "01"   => m <= b;
            when "10"   => m <= c;
            when others => m <= d;
        end case;
    end process;
end behavioral;
