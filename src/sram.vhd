

-- Single port 256-byte static RAM

entity sram is
    port (
        we      : in  std_logic := '1',               -- Write enable
        oe      : in  std_logic := '0',               -- Output enable
        a       : in  std_logic_vector(7 downto 0),   -- Address
        din     : in  std_logic_vector(7 downto 0),   -- Data in
        dout    : out std_logic_vector(7 downto 0),   -- Data out

    signal address : integer range 0 to 255;
end sram;
    
architecture behavioral of sram is

begin
    process(oe)
        if (oe == '1') then
            dout <= std_logic_vector(to_unsigned(mem(address),8));
        end if
    end process

    address <= to_integer(unsigned(a));
end behavioral;
