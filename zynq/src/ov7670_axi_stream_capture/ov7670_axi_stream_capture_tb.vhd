library ieee;
use ieee.std_logic_1164.all;

entity ov7670_axi_stream_capture_tb is
end ov7670_axi_stream_capture_tb;

architecture behavior of ov7670_axi_stream_capture_tb is
    constant t_byte : time := 20 ns;
    constant t_pixel : time := 2 * t_byte;
    constant t_line : time := 784 * t_pixel;

    component ov7670_axi_stream_capture is
        port (
            pclk          : in  std_logic;
            vsync         : in  std_logic;
            href          : in  std_logic;
            d             : in  std_logic_vector (7 downto 0);
            m_axis_tvalid : out std_logic;
            m_axis_tready : in  std_logic;
            m_axis_tlast  : out std_logic;
            m_axis_tdata  : out std_logic_vector ( 31 downto 0 );
            m_axis_tuser  : out std_logic;
            aclk          : out std_logic
        );
    end component;
    
    signal in_pclk          : std_logic := '0';
    signal in_vsync         : std_logic := '0';
    signal in_href          : std_logic := '0';
    signal in_d             : std_logic_vector (7 downto 0) := "11111111";
    signal out_m_axis_tvalid : std_logic;
    signal out_m_axis_tready : std_logic;
    signal out_m_axis_tlast  : std_logic;
    signal out_m_axis_tdata  : std_logic_vector ( 31 downto 0 );
    signal out_m_axis_tuser  : std_logic;
    signal out_aclk          : std_logic;

begin
    uut: ov7670_axi_stream_capture port map (
        pclk => in_pclk,
        vsync => in_vsync,
        href => in_href,
        d => in_d,
        m_axis_tvalid => out_m_axis_tvalid,
        m_axis_tready => out_m_axis_tready,
        m_axis_tlast => out_m_axis_tlast,
        m_axis_tdata => out_m_axis_tdata,
        m_axis_tuser => out_m_axis_tuser,
        aclk => out_aclk
    );
    
   clk_process :process
   begin
        in_pclk <= '0';
        wait for 10 ns;
        in_pclk <= '1';
        wait for 10 ns;
   end process;
   
    vsync_process: process
    begin
        in_vsync <= '0';
        wait for 5 * t_line;
        in_vsync <= '1';
        wait for 3 * t_line;
        in_vsync <= '0';
        wait for (510-3-5)*t_line;
    end process;
    
    href_process: process
    begin
        in_href <= '0';
        wait until falling_edge(in_vsync);
        wait for 17 * t_line;
        for i in 0 to 480 loop -- Count over lines
            in_href <= '1';
            wait for 640 * t_pixel; -- Pixels are actually transmitted here, rest is garbage
            in_href <= '0';
            wait for 144 * t_pixel;
        end loop;
    end process;

    stim_proc: process
    begin
        wait until rising_edge(in_pclk);
        in_d <= "10101010";
    end process;
end;
