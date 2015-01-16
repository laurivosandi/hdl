library ieee;
use ieee.std_logic_1164.all;


entity bcd_segment_driver is
    port (
        bcd      : in  std_logic_vector(3 downto 0);
        segments : out std_logic_vector(6 downto 0));
end;

architecture behavioral of bcd_segment_driver is
begin
    segments <=
        "1111110" when bcd = "0000" else -- 0
        "0110000" when bcd = "0001" else -- 1
        "1101101" when bcd = "0010" else -- 2
        "1111001" when bcd = "0011" else -- 3
        "0110011" when bcd = "0100" else -- 4
        "1011011" when bcd = "0101" else -- 5
        "1011111" when bcd = "0110" else -- 6
        "1110000" when bcd = "0111" else -- 7
        "1111111" when bcd = "1000" else -- 8
        "1111011" when bcd = "1001" else -- 9
        "0000000";
end;

