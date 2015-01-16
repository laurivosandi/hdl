library ieee;
use ieee.std_logic_1164.all;

entity frequency_divider is
    generic (
        RATIO : integer := 50000000);
    port (
        clk_in  : in  std_logic;
        reset   : in  std_logic;
        clk_out : out std_logic);
end;

architecture behavioral of frequency_divider is
    signal temporal: std_logic;
    signal counter : integer range 0 to RATIO := 0;
begin
    frequency_divider_process: process (reset, clk_in) begin
        if (reset = '1') then
            temporal <= '0';
            counter <= 0;
        elsif rising_edge(clk_in) then
            if (counter = RATIO) then
                temporal <= not(temporal);
                counter <= 0;
            else
                counter <= counter + 1;
            end if;
        end if;
    end process;
    clk_out <= temporal;
end;


