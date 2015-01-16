library ieee;
use ieee.std_logic_1164.all;

entity tristate_buffer_testbench is end tristate_buffer_testbench;

architecture behave of tristate_buffer_testbench is
    signal in1, in2       : std_logic_vector (1 downto 0) := "00";
    signal ctrl, ctrl_inv : std_logic := '0';
    signal data_bus       : std_logic_vector (1 downto 0);

    component tristate_buffer
        generic (
            size : integer
        );
        port (
            enable  : in    std_logic;
            d_in    : in    std_logic_vector (size -1 downto 0);
            d_out   : out   std_logic_vector (size -1 downto 0)
        );
    end component;
begin
    in1 <=
        "00",
        "01" after 40 ns,
        "00" after 80 ns,
        "01" after 120 ns;
    in2  <=
        "10",
        "11" after 80 ns;
        
    ctrl <= not ctrl after 20 ns;
    ctrl_inv <= not ctrl after 7 ns; --TTL delay in inverter
  
    uut1 : tristate_buffer
        generic map (
            size => 2
        )
        port map (
            d_in   => in1,
            enable => ctrl,
            d_out  => data_bus
        );

    uut2 : tristate_buffer
        generic map (
            size => 2
        )
        port map (
            d_in   => in2,
            enable => ctrl_inv,
            d_out  => data_bus
        );

end;


