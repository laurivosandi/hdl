library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gray_testbench is end gray_testbench;

architecture behavioral of gray_testbench is
    signal input : std_logic_vector(3 downto 0);
    signal output : std_logic_vector(3 downto 0);

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
        for j in 0 to 15 loop
            input <= std_logic_vector(to_unsigned(j,4));
            wait for 10 ns;
        end loop;
    end process;
    
    output(3) <= input(3);

    uut1 : mux
        port map (
            a => '0',
            b => '1',
            c => '1',
            d => '0',
            s => input(3 downto 2),
            m => output(2)
        );
        
    uut2 : mux
        port map (
            a => '0',
            b => '1',
            c => '1',
            d => '0',
            s => input(2 downto 1),
            m => output(1)
        );
        
    uut3 : mux
        port map (
            a => '0',
            b => '1',
            c => '1',
            d => '0',
            s => input(1 downto 0),
            m => output(0)
        );
end;


