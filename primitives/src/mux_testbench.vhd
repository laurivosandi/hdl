library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mux_testbench is end mux_testbench;

architecture behavioral of mux_testbench is
    signal d : std_logic_vector(3 downto 0);
    signal s : std_logic_vector(1 downto 0);
    signal m : std_logic;

    component mux
        port (
            a : in  std_logic;
            b : in  std_logic;
            c : in  std_logic;
            d : in  std_logic;
            s : in  std_logic_vector(1 downto 0);
            m : out std_logic
        );
    end component;
begin
    process begin
        for i in 0 to 3 loop
            s <= std_logic_vector(to_unsigned(i,2));
            for j in 0 to 15 loop
                d <= std_logic_vector(to_unsigned(j,4));
                wait for 10 ns;
            end loop;
        end loop;
    end process;

    uut1 : mux
        port map (
            a => d(0),
            b => d(1),
            c => d(2),
            d => d(3),
            s => s,
            m => m
        );
end;


