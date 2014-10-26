library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL; -- Import to_integer, to_signed

entity carry_ripple_adder_testbench is
end carry_ripple_adder_testbench;

architecture behavior of carry_ripple_adder_testbench is 
    component carry_ripple_adder is
        generic (
            WIDTH : integer := 8);
        port (
            a  : in  std_logic_vector (7 downto 0);
            b  : in  std_logic_vector (7 downto 0);
            ci : in  std_logic;
            s  : out std_logic_vector (7 downto 0);
            co : out  std_logic);
    end component;
    signal a : std_logic_vector(7 downto 0);
    signal b : std_logic_vector(7 downto 0);
    signal s : std_logic_vector(7 downto 0);
    signal ci : std_logic;
    signal co : std_logic;
begin
    uut: carry_ripple_adder port map (
          a => a,
          b => b,
          ci => ci,
          s => s,
          co => co
    );

    stim_proc: process
    begin
        for i in -63 to 63 loop
            for j in -63 to 63 loop
                ci <= '0';
                a <= std_logic_vector(to_signed(i, 8));
                b <= std_logic_vector(to_signed(j, 8));
                wait for 10 ns;
                assert i + j = to_integer(signed(s))
                    report integer'image(i) & " + " & integer'image(j) & " was " & integer'image(to_integer(signed(s)));
                -- TODO: Check carry out
--                assert i < 0 and j <  0 and to_integer(signed(s)) > 0 and (co = '0');
--                    report integer'image(i) & " + " & integer'image(j) & " had carry out";
            end loop;
        end loop;
        for i in -63 to 63 loop
            for j in -63 to 63 loop
                ci <= '1';
                a <= std_logic_vector(to_signed(i, 8));
                b <= std_logic_vector(to_signed(j, 8));
                wait for 10 ns;
                assert i + j + 1 = to_integer(signed(s))
                    report integer'image(i) & " + " & integer'image(j) & " was " & integer'image(to_integer(signed(s)));
                -- TODO: Check carry out
            end loop;
        end loop;
        report "Carry ripple added tested summation of all 8-bit signed numbers";
        wait;	
    end process;
end;
