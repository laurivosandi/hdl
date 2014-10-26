
library ieee;
use work.open_collector.all;

entity open_collector_testbench is end open_collector_testbench;

architecture behavioral of open_collector_testbench IS
    signal a : opc_logic;
    signal b : opc_logic;
    signal bus_wire : opc_logic;
    signal clk1 : bit;
    signal clk2 : bit;
begin
    process
    begin
        for i in opc_ulogic loop
            a <= i;
            bus_wire <= i;
            wait on clk1 until clk1 = '1';
            report "a:" & opc_logic'image(a) & " b:" & opc_logic'image(b) & " bus_wire:" & opc_logic'image(bus_wire);
        end loop;
    end process;

    process
    begin
        for j in opc_ulogic loop
            b <= j;
            bus_wire <= j;
            wait on clk2 until clk2 = '1';
        end loop;
    end process;

    clk1 <= not(clk1) after 10 ns;
    clk2 <= not(clk2) after 50 ns;
    
end behavioral;
