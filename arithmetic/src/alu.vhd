library ieee;
use ieee.std_logic_1164.all;

entity alu is
    generic (
        WIDTH: integer := 8
    );
    port (
        a    : in  std_logic_vector (WIDTH-1 downto 0);
        b    : in  std_logic_vector (WIDTH-1 downto 0);
        cin  : in  std_logic;
        ctrl : in  std_logic_vector (      1 downto 0);
        cout : out std_logic;
        q    : out std_logic_vector (WIDTH-1 downto 0)
    );
end alu;

architecture behavioral of alu is
    component carry_ripple_adder
        generic (
            WIDTH : integer
        );
        port (
            a  : in  std_logic_vector (WIDTH-1 downto 0);
            b  : in  std_logic_vector (WIDTH-1 downto 0);
            ci : in  std_logic;
            s  : out std_logic_vector (WIDTH-1 downto 0);
            co : out std_logic
        );
    end component;

    signal operand1                   : std_logic_vector (WIDTH-1 downto 0);
    signal operand2                   : std_logic_vector (WIDTH-1 downto 0);
    signal operand2_complement        : std_logic_vector (WIDTH-1 downto 0);
    signal sum                        : std_logic_vector (WIDTH-1 downto 0);
    signal sum_carry                  : std_logic;
    signal difference                 : std_logic_vector (WIDTH-1 downto 0);
    signal difference_carry           : std_logic;

begin
    -- Connect inputs
    operand1 <= a;
    operand2 <= b;
    
    -- Addition
    adder1: carry_ripple_adder
        generic map(
            WIDTH
        )
        port map(
            a => operand1,
            b => operand2,
            ci => '0',
            s => sum,
            co => sum_carry
        );

    -- Subtraction
    operand2_complement <= not operand2;    
        
    adder2: carry_ripple_adder 
        generic map(
            WIDTH
        )
        port map(
            a => operand1,
            b => operand2_complement,
            ci => '1',
            s => difference,
            co => difference_carry
        );

    -- Control logic and inlined NOR and NAND operations
    q <=    sum                         when ctrl ="00" else
            difference                  when ctrl ="01" else
            operand1 nor operand2       when ctrl ="10" else
            operand1 nand operand2      when ctrl ="11" else
            (others => '0');

    -- Carry bit
    cout <= sum_carry          when ctrl = "00" else
            difference_carry   when ctrl = "01" else
            '0';
end;
