library ieee;
use ieee.STD_LOGIC_1164.all;
use std.textio.all;

entity goldschmidt_division is
    port (
        a   : in std_logic_vector (15 downto 0);   -- Dividend
        b   : in std_logic_vector (15 downto 0);   -- Divisor
        c   : in std_logic_vector (2 downto 0);    -- Iteration count
        clk : in std_logic;
        rst : in std_logic;
        q   : out std_logic_vector (15 downto 0)   -- Quotinent
    );
end goldschmidt_division;

architecture behavioral of goldschmidt_division is
    -- Booth multiplier
    component multiplier is
        port (
            a : in  std_logic_vector (15 downto 0);
            b : in  std_logic_vector (15 downto 0);
            m : out std_logic_vector (31 downto 0)
        );
    end component;
    
    -- Carry lookahead adder
    component cla is
        generic (N : integer := 16);
        port (
            a  : in  std_logic_vector (N-1 downto 0);
            b  : in  std_logic_vector (N-1 downto 0);
            ci : in  std_logic;
            s  : out std_logic_vector (N-1 downto 0);
            co : out std_logic
        );
    end component;

    -- Reciprocal approximator
    component reciprocal is
        port (
            b : in  std_logic_vector (15 downto 0);
            r : out std_logic_vector (15 downto 0)
        );
    end component;

    -- Counter register
    signal counter : std_logic_vector(2 downto 0);
    signal counter_decremented : std_logic_vector(2 downto 0);
    
    -- Intermediate output signals
    signal nop : std_logic_vector(31 downto 0);
    signal dop : std_logic_vector(31 downto 0);
    signal dos : std_logic_vector(15 downto 0);
    signal don : std_logic_vector(15 downto 0);
   
    -- Current iteration outputs
    signal no : std_logic_vector(15 downto 0);
    signal do : std_logic_vector(15 downto 0);
    signal fo : std_logic_vector(15 downto 0);
    
    -- Previous iteration registers
    signal np : std_logic_vector(15 downto 0);
    signal dp : std_logic_vector(15 downto 0);
    signal fp : std_logic_vector(15 downto 0);
    
    -- Initial reciprocal
    signal ir : std_logic_vector(15 downto 0);

begin
    -- Dump output process
    dump_proc: process
    file OUTPUT_FILE : text open write_mode is "dump.txt";
    variable output_line: LINE;
    begin		
	    for i in 1 to 10 loop
            wait until rising_edge(clk);
            write(output_line,to_bitvector(no));
            writeline(output_file,output_line);
	    end loop;	
    end process;

    -- Registers for N, D and F
    sync_process: process(clk, counter)
    begin
        if (rst = '1') then
            counter <= c;
            np <= a;
            dp <= b;
            fp <= ir;
        elsif rising_edge(clk) then
            counter <= counter_decremented;
            np <= no;
            dp <= do;
            fp <= fo;
        end if;
    end process;
    
    -- Have initial reciprocal always ready to go
    initial_reciprocal: reciprocal port map(b=>b, r=>ir);
    
    -- Decrement iteration counter
    counter_decremented <=
        "110" when counter = "111" else
        "101" when counter = "110" else
        "100" when counter = "101" else
        "011" when counter = "100" else
        "010" when counter = "011" else
        "001" when counter = "010" else
        "000";

    -- Multiply input F and input N
    n_stage: multiplier port map(a=>fp, b=>np, m=>nop);
    
    -- Multiply input F and input D
    d_stage: multiplier port map(a=>fp, b=>dp, m=>dop);
    
    -- Round output N
    no <= nop(23 downto 8);
    
    -- Round output D
    dos <= dop(23 downto 8);
    
    -- Find two's complement of output D
    don <= not dos;
    
    -- Subtract D from 2
    f_stage: cla port map(a=>"0000001000000000", b=>don, ci=>'1', s=>fo);
    do <= dos;
        
    -- Bind outputs
    q <= no;

end behavioral;
