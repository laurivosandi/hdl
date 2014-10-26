library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bcd_counter is
    port (
        clk_in  : in  std_logic;
        reset   : in  std_logic;
        inc     : in  std_logic;
        bcd     : out std_logic_vector(3 downto 0);
        clk_out : out std_logic);
end;

architecture behavioral of bcd_counter is
    signal temporal: std_logic;
    signal counter : integer range 0 to 10;
begin
    counter_process: process (reset, clk_in) begin
        if (reset = '1') then
            temporal <= '0';
            counter <= 0;
        elsif rising_edge(clk_in) then
            if inc = '1' then
                if (counter = 9) then
                    temporal <= '1';
                    counter <= 0;
                else
                    temporal <= '0';
                    counter <= counter + 1;
                end if;
            else
                if (counter = 0) then
                    temporal <= '1';
                    counter <= 9;
                else
                    temporal <= '0';
                    counter <= counter - 1;
                end if;
            end if;
        end if;
    end process;
    
    clk_out <= temporal;
    bcd <= std_logic_vector(to_unsigned(counter,4));
end;
