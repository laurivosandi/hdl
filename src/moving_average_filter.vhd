library ieee;
use ieee.std_logic_1164.all;

entity moving_average_filter is
    port (
        sin  : in  std_logic_vector (10 downto 0);
        clk  : in  std_logic;
        sout : out std_logic_vector (10 downto 0);
        rst  : in  std_logic
    );
end moving_average_filter;

architecture behavioral of moving_average_filter is
    -- Registers
    type tregisters is array (0 to 15) of std_logic_vector(14 downto 0);
    signal r : tregisters;

    -- Padded input value
    signal first : std_logic_vector(14 downto 0);

    -- First stage
    signal s11 : std_logic_vector(14 downto 0);
    signal s12 : std_logic_vector(14 downto 0);
    signal s13 : std_logic_vector(14 downto 0);
    signal s14 : std_logic_vector(14 downto 0);
    signal c11 : std_logic_vector(14 downto 0);
    signal c12 : std_logic_vector(14 downto 0);
    signal c13 : std_logic_vector(14 downto 0);
    signal c14 : std_logic_vector(14 downto 0);

    -- Second stage
    signal s21 : std_logic_vector(14 downto 0);
    signal s22 : std_logic_vector(14 downto 0);
    signal c21 : std_logic_vector(14 downto 0);
    signal c22 : std_logic_vector(14 downto 0);
    signal s22s : std_logic_vector(14 downto 0);
    signal c21s : std_logic_vector(14 downto 0);
    signal c22s : std_logic_vector(14 downto 0);

    -- Third stage
    signal s3 : std_logic_vector(14 downto 0);
    signal c3 : std_logic_vector(14 downto 0);
    signal c3s : std_logic_vector(14 downto 0);

    -- Final sum
    signal s : std_logic_vector(14 downto 0);
    signal c : std_logic_vector(15 downto 0);

    component counter42 is
        Port ( a : in  std_logic_vector (14 downto 0);
               b : in  std_logic_vector (14 downto 0);
               c : in  std_logic_vector (14 downto 0);
               d : in  std_logic_vector (14 downto 0);
               s : out  std_logic_vector (14 downto 0);
               co : out  std_logic_vector (14 downto 0));
    end component;


    component carry_lookahead_adder is
        Port ( a : in  std_logic_vector (14 downto 0);
               b : in  std_logic_vector (14 downto 0);
               ci : in  std_logic;
               s : out  std_logic_vector (14 downto 0);
               co : out  std_logic);
    end component;


begin
    process (sin, clk)
    begin
        if rst = '1' then
            -- Reset register
            for i in 0 to 15 loop
                r(i) <= "000000000000000";
            end loop;
        elsif rising_edge(clk) then
            -- Shift operands
            for i in 15 downto 1 loop
                r(i) <= r(i-1);
            end loop;

            -- Store first operand
            r(0) <= first;
        end if;
    end process;

    -- Sign extension
    sign_extension_loop: for i in 14 downto 11 generate
        first(i) <= sin(10);
    end generate;
    
    -- Connect lower 11-bits
    input_loop: for i in 10 downto 0 generate
        first(i) <= sin(i);
    end generate;
    
    -- First stage
    stg11: counter42 port map(a=>first, b=>r( 0), c=>r( 1), d=>r( 2), s=>s11, co=>c11);
    stg12: counter42 port map(a=>r( 3), b=>r( 4), c=>r( 5), d=>r( 6), s=>s12, co=>c12);
    stg13: counter42 port map(a=>r( 7), b=>r( 8), c=>r( 9), d=>r(10), s=>s13, co=>c13);
    stg14: counter42 port map(a=>r(11), b=>r(12), c=>r(13), d=>r(14), s=>s14, co=>c14);

    -- Second stage: Sum shifted carries & sums
    stg21: counter42 port map(a=>s11, b=>s12, c=>s13, d=>s14, s => s21, co => c21);
    stg22: counter42 port map(a=>c11, b=>c12, c=>c13, d=>c14, s => s22, co => c22);
    s22s <= s22(13 downto 0) & "0";   -- s22 is shifted by 1
    c21s <= c21(13 downto 0) & "0";   -- c21 is shifted by 1
    c22s <= c22(12 downto 0) & "00";  -- c22 is shifted by 2
    
    -- Third stage
    stg3:  counter42 port map(a=>s21, b=>s22s, c=>c21s, d=>c22s, s=>s3, co => c3);
    c3s <= c3(13 downto 0) & "0";     -- c3 is shifted by 1
    
    -- Final addition
    stg4: carry_lookahead_adder port map(a=>s3, b=>c3s, ci=>'0', s=>s);
    
    -- Write output
    division_loop: for i in 10 downto 0 generate
        sout(i) <= s(i+4);
    end generate;

end Behavioral;
