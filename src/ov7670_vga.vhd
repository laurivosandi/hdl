----------------------------------------------------------------------------------
-- Engineer: Mike Field <hamster@snap.net.nz>
-- 
-- Description: Generate analog 640x480 VGA, double-doublescanned from 19200 bytes of RAM
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ov7670_vga is
    port ( 
        clk25       : in  STD_LOGIC;
        vga_red     : out STD_LOGIC_VECTOR(4 downto 0);
        vga_green   : out STD_LOGIC_VECTOR(5 downto 0);
        vga_blue    : out STD_LOGIC_VECTOR(4 downto 0);
        vga_hsync   : out STD_LOGIC;
        vga_vsync   : out STD_LOGIC;
        frame_addr  : out STD_LOGIC_VECTOR(17 downto 0);
        frame_pixel : in  STD_LOGIC_VECTOR(11 downto 0)
    );
end ov7670_vga;

architecture Behavioral of ov7670_vga is
   -- Timing constants
   constant hRez       : natural := 640;
   constant hStartSync : natural := 640+16;
   constant hEndSync   : natural := 640+16+96;
   constant hMaxCount  : natural := 800;
   
   constant vRez       : natural := 480;
   constant vStartSync : natural := 480+10;
   constant vEndSync   : natural := 480+10+2;
   constant vMaxCount  : natural := 480+10+2+33;
   
   constant hsync_active : std_logic := '0';
   constant vsync_active : std_logic := '0';

   signal hCounter : unsigned( 9 downto 0) := (others => '0');
   signal vCounter : unsigned( 9 downto 0) := (others => '0');
   signal address  : unsigned(18 downto 0) := (others => '0');
   signal blank    : std_logic := '1';

begin
   frame_addr <= std_logic_vector(address(18 downto 1));
   
   process(clk25)
   begin
      if rising_edge(clk25) then
         -- Count the lines and rows      
         if hCounter = hMaxCount-1 then
            hCounter <= (others => '0');
            if vCounter = vMaxCount-1 then
               vCounter <= (others => '0');
            else
               vCounter <= vCounter+1;
            end if;
         else
            hCounter <= hCounter+1;
         end if;

         if blank = '0' then
            vga_red   <= frame_pixel(11 downto 8) & "0";
            vga_green <= frame_pixel( 7 downto 4) & "00";
            vga_blue  <= frame_pixel( 3 downto 0) & "0";
         else
            vga_red   <= (others => '0');
            vga_green <= (others => '0');
            vga_blue  <= (others => '0');
         end if;
   
         if vCounter  >= vRez then
            address <= (others => '0');
            blank <= '1';
         else 
            if hCounter  < 640 then
               blank <= '0';
               address <= address+1;
            else
               blank <= '1';
            end if;
         end if;
   
         -- Are we in the hSync pulse? (one has been added to include frame_buffer_latency)
         if hCounter > hStartSync and hCounter <= hEndSync then
            vga_hSync <= hsync_active;
         else
            vga_hSync <= not hsync_active;
         end if;

         -- Are we in the vSync pulse?
         if vCounter >= vStartSync and vCounter < vEndSync then
            vga_vSync <= vsync_active;
         else
            vga_vSync <= not vsync_active;
         end if;
      end if;
   end process;
end Behavioral;
