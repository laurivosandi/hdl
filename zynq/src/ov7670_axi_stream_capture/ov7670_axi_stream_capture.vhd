----------------------------------------------------------------------------------
-- Authors: Mike Field <hamster@snap.net.nz>
--          Lauir Vosandi <lauri.vosandi@gmail.com>
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ov7670_axi_stream_capture is
    port (
        pclk              : in  std_logic;
        vsync             : in  std_logic;
        href              : in  std_logic;
        d                 : in  std_logic_vector (7 downto 0);
        m_axis_tvalid     : out std_logic;
        m_axis_tready     : in  std_logic;
        m_axis_tlast      : out std_logic;
        m_axis_tdata      : out std_logic_vector ( 31 downto 0 );
        m_axis_tuser      : out std_logic;
        aclk              : out std_logic
    );
end ov7670_axi_stream_capture;

architecture behavioral of ov7670_axi_stream_capture is
    signal d_latch          : std_logic_vector(15 downto 0) := (others => '0');
    signal address          : std_logic_vector(18 downto 0) := (others => '0');
    signal line             : std_logic_vector(1 downto 0)  := (others => '0');
    signal href_last        : std_logic_vector(6 downto 0)  := (others => '0');
    signal we_reg           : std_logic := '0';
    signal href_hold        : std_logic := '0';
    signal latched_vsync    : std_logic := '0';
    signal latched_href     : std_logic := '0';
    signal latched_d        : std_logic_vector (7 downto 0) := (others => '0');
    signal sof              : std_logic := '0';
    signal eol              : std_logic := '0';
begin
     -- Expand 16-bit RGB (5:6:5) to 32-bit RGBA (8:8:8:8)
     m_axis_tdata  <= "11111111"  & d_latch(4 downto 0) & d_latch(0) & d_latch(0) & d_latch(0) & d_latch(10 downto 5) & d_latch(5) & d_latch(5) & d_latch(15 downto 11) & d_latch(11) & d_latch(11) & d_latch(11);
     m_axis_tvalid <= we_reg;
     m_axis_tlast <= eol;
     m_axis_tuser <= sof;
     aclk <= not pclk;

capture_process: process(pclk)
begin
    if rising_edge(pclk) then
        if we_reg = '1' then
            address <= std_logic_vector(unsigned(address)+1);
        end if;

        if href_hold = '0' and latched_href = '1' then
            case line is
                when "00" => line <= "01";
                when "01" => line <= "10";
                when "10" => line <= "11";
                when others => line <= "00";
            end case;
        end if;
        href_hold <= latched_href;
        
        -- Capturing the data from the camera
        if latched_href = '1' then
            d_latch <= d_latch( 7 downto 0) & latched_d;
        end if;
        we_reg  <= '0';

        -- Is a new screen about to start (i.e. we have to restart capturing)
        if latched_vsync = '1' then 
            address        <= (others => '0');
            href_last     <= (others => '0');
            line            <= (others => '0');
        else
            -- If not, set the write enable whenever we need to capture a pixel
            if href_last(0) = '1' then
                we_reg <= '1';
                href_last <= (others => '0');
            else
                href_last <= href_last(href_last'high-1 downto 0) & latched_href;
            end if;
        end if;
        
        case unsigned(address) mod 640 = 639 is
            when true => eol <= '1';
            when others => eol <= '0';
        end case;
        
        case unsigned(address) = 0 is
            when true => sof <= '1';
            when others => sof <= '0';
        end case;
    end if;
    if falling_edge(pclk) then
        latched_d     <= d;
        latched_href  <= href;
        latched_vsync <= vsync;
    end if;
end process;
end behavioral;
