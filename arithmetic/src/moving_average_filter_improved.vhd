library ieee;
use ieee.std_logic_1164.all;

entity moving_average_filter is
    Port ( sin  : in  std_logic_vector (10 downto 0);
           clk  : in  std_logic;
           sout : out std_logic_vector (10 downto 0);
           rst  : in  std_logic);
end moving_average_filter;

architecture behavioral of moving_average_filter is
    -- Registers
    type tregisters is array (0 to 15) of std_logic_vector(14 downto 0);
    signal registers : tregisters;
    signal sum : std_logic_vector(14 downto 0);

    -- Wires
    signal addition              : std_logic_vector(14 downto 0);
    signal addition_carries      : std_logic_vector(14 downto 0);
    signal subtraction           : std_logic_vector(14 downto 0);
    signal subtraction_carries   : std_logic_vector(14 downto 0);
    signal first                 : std_logic_vector(14 downto 0);
    signal last                  : std_logic_vector(14 downto 0);

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
                registers(i) <= "000000000000000";
            end loop;
            sum <= "000000000000000";
        elsif rising_edge(clk) then
            -- Shift operands
            for i in 15 downto 1 loop
                registers(i) <= registers(i-1);
            end loop;

            -- Store first operand
            registers(0) <= first;

            -- Store sumious value
            sum <= subtraction;
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

    -- Last operand
    last <= not (registers(15));

    -- Add first operand
    addition_stage: carry_lookahead_adder port map(a=>first, b=>sum, ci=>'0', s=>addition);
    
    -- Subtract last operand
    subtraction_stage: carry_lookahead_adder port map(a=>addition, b=>last, ci=>'1', s=>subtraction);
    
    -- Write output
    division_loop: for i in 10 downto 0 generate
        sout(i) <= subtraction(i+4);
    end generate;

end Behavioral;
