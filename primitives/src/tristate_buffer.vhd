library ieee;
use ieee.std_logic_1164.all;

entity tristate_buffer is
    generic (
        size    : integer
    );
    port (
        enable  : in    std_logic;
        d_in    : in    std_logic_vector (size -1 downto 0);
        d_out   : out   std_logic_vector (size -1 downto 0)
    );
end;

architecture behaviour of tristate_buffer is
    signal enable_int : std_logic;
begin
    process ( d_in, enable )
    begin
        if enable = '1' then
            d_out <= d_in after 7 ns; -- TTL delay in tristate buffer
        else
            d_out <= (others => 'Z') after 7 ns;
        end if;
    end process;
end;
