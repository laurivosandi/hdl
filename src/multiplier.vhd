library ieee;
use ieee.std_logic_1164.all;

entity multiplier is
    port (
        a : in  std_logic_vector (15 downto 0);
        b : in  std_logic_vector (15 downto 0);
        m : out std_logic_vector (31 downto 0)
    );
end multiplier;

architecture behavioral of multiplier is
    -- Booth encoder
    component booth4 is
        port (
            a  : in  std_logic_vector (15 downto 0);
            d  : in  std_logic_vector (2 downto 0);
            m  : out std_logic_vector (16 downto 0)
        );
    end component;
    
    -- Bit-vector based 4:2 counter
    component counter42 is
        generic (N : integer := 24);
        port (
            a  : in  std_logic_vector (N-1 downto 0);
            b  : in  std_logic_vector (N-1 downto 0);
            c  : in  std_logic_vector (N-1 downto 0);
            d  : in  std_logic_vector (N-1 downto 0);
            s  : out std_logic_vector (N-1 downto 0);
            co : out std_logic_vector (N-1 downto 0)
        );
    end component;

    -- Carry lookahead adder
    component cla is
        generic (N : integer := 32);
        port (
            a  : in  std_logic_vector (N-1 downto 0);
            b  : in  std_logic_vector (N-1 downto 0);
            ci : in  std_logic;
            s  : out std_logic_vector (N-1 downto 0);
            co : out std_logic
        );
    end component;

    -- First Booth digit
    signal d0   : std_logic_vector(2 downto 0);

    -- Products
    signal p0   : std_logic_vector(16 downto 0);
    signal p1   : std_logic_vector(16 downto 0);
    signal p2   : std_logic_vector(16 downto 0);
    signal p3   : std_logic_vector(16 downto 0);
    signal p4   : std_logic_vector(16 downto 0);
    signal p5   : std_logic_vector(16 downto 0);
    signal p6   : std_logic_vector(16 downto 0);
    signal p7   : std_logic_vector(16 downto 0);
    
    -- Sign extension
    signal se0  : std_logic_vector(23 downto 0);
    signal se1  : std_logic_vector(23 downto 0);
    signal se2  : std_logic_vector(23 downto 0);
    signal se3  : std_logic_vector(23 downto 0);
    signal se4  : std_logic_vector(23 downto 0);
    signal se5  : std_logic_vector(23 downto 0);
    signal se6  : std_logic_vector(23 downto 0);
    signal se7  : std_logic_vector(23 downto 0);
    
    -- Intermediary sums and carries
    signal s1   : std_logic_vector(23 downto 0);
    signal s2   : std_logic_vector(23 downto 0);
    signal co1  : std_logic_vector(23 downto 0);
    signal co2  : std_logic_vector(23 downto 0);
    
    -- Final sum and carry
    signal s3   : std_logic_vector(31 downto 0);
    signal co3  : std_logic_vector(31 downto 0);
    
    -- Padded sums abd carries
    signal s1p  : std_logic_vector(31 downto 0);
    signal s2p  : std_logic_vector(31 downto 0);
    signal co1p : std_logic_vector(31 downto 0);
    signal co2p : std_logic_vector(31 downto 0);
    signal co3p : std_logic_vector(31 downto 0);
begin
    -- Pad first booth digit
    d0 <= b( 1 downto  0) & "0";
    
    -- Product stages
    p0_stage: booth4 port map(a=>a, d=>d0, m=>p0);
    p1_stage: booth4 port map(a=>a, d=>b( 3 downto  1), m=>p1);
    p2_stage: booth4 port map(a=>a, d=>b( 5 downto  3), m=>p2);
    p3_stage: booth4 port map(a=>a, d=>b( 7 downto  5), m=>p3);
    p4_stage: booth4 port map(a=>a, d=>b( 9 downto  7), m=>p4);
    p5_stage: booth4 port map(a=>a, d=>b(11 downto  9), m=>p5);
    p6_stage: booth4 port map(a=>a, d=>b(13 downto 11), m=>p6);
    p7_stage: booth4 port map(a=>a, d=>b(15 downto 13), m=>p7);

    -- Reduced sign extension, assuming that compiler takes
    -- care of getting rid of constants of course
    se0 <= "0000" & (not p0(16)) & p0(16) & p0(16) & p0;
    se1 <= "0001" & (not p1(16))            & p1 & "00";
    se2 <= "01" & (not p2(16))            & p2 & "0000";
    se3 <= not(p3(16))                  & p3 & "000000";
    
    se4 <= "000001" & (not p4(16))                 & p4;
    se5 <= "0001" & (not p5(16))            & p5 & "00";
    se6 <= "01" & (not p6(16))            & p6 & "0000";
    se7 <= not(p7(16))                  & p7 & "000000";
    
    -- Add first 4 products
    counter_stage1: counter42 port map(
        a => se0, b => se1, c => se2, d => se3,
        s => s1, co => co1);
        
    -- Add remaining 4 products
    counter_stage2: counter42 port map(
        a => se4, b => se5, c => se6, d => se7,
        s => s2, co => co2);
        
    -- Pad carries
    s1p  <= "00000001" & s1;
    s2p  <= s2 & "00000000";
    co1p <= "0000000" & co1 & "0";
    co2p <= co2(22 downto 0) & "000000000";
        
    -- Add shifted operands
    counter_stage3: counter42 generic map (N=>32) port map(
        a => s1p,
        b => s2p,
        c => co1p,
        d => co2p,
        s => s3,
        co => co3
    );
    
    -- Pad carries
    co3p <= co3(30 downto 0) & "0";

    -- Add sum and carries
    cla_stage2: cla port map(
        a => s3, b => co3p, ci => '0', s => m
    );
end behavioral;
