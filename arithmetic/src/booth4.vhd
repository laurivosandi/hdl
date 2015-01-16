library ieee;
use ieee.std_logic_1164.all;

-- Consider multiplication of a and b:
-- d is radix-4 booth encoded bits of digit of the multiplier b
-- a is the bit vector of multiplicand
-- n is the 2's complement of a
-- m is the multiplication of d and a
entity booth4 is
    Port ( a : in  std_logic_vector (15 downto 0);
           d : in  std_logic_vector (2 downto 0);
           m : out std_logic_vector (16 downto 0));
end booth4;

architecture behavioral of booth4 is
    component cla is
        generic (N : integer := 16);
        port (
            a  : in  std_logic_vector (N-1 downto 0);
            b  : in  std_logic_vector (N-1 downto 0);
            ci : in  std_logic;
            s  : out std_logic_vector (N-1 downto 0);
            co : out std_logic
        );
    end component;

    -- Signals for two's complement
    signal ai : std_logic_vector(15 DOWNTO 0);
    signal an : std_logic_vector(15 DOWNTO 0);

begin
    -- Two's complement of a,
    -- assuming that of course compiler takes care of 
    -- getting rid of duplicate two's complement circuits
    ai <= not a;
    cla_stage: cla generic map (N=>16)  port map(
      a => ai, b => "0000000000000001", ci => '0', s => an
    );
    
    -- Dummy lookup table
    with d select 
        m <=a(15)  & a   when "001", -- Sign expanded addition
            a(15)  & a   when "010", -- Same as previous
            a      & "0" when "011", -- Add double
            an     & "0" when "100", -- Subtract double
            an(15) & an  when "101", -- Sign expanded subtraction
            an(15) & an  when "110",
            "00000000000000000" when others;
end behavioral;
