use work.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu_testbench is
end;

architecture behavioral of alu_testbench is
    constant TB_WIDTH : integer := 8;
    signal a, b, q     : std_logic_vector(TB_WIDTH-1 downto 0);
    signal ctrl        : std_logic_vector (1 DOWNTO 0);
    signal cout, cin   : std_logic := '0';

    component alu
        generic (
            WIDTH: INTEGER:= TB_WIDTH);
        port (
            a       : in  std_logic_vector (WIDTH-1 downto 0);
            b       : in  std_logic_vector (WIDTH-1 downto 0);
            cin     : in  std_logic;
            ctrl    : in  std_logic_vector (      1 downto 0);
            cout    : out std_logic;
            q       : out std_logic_vector (WIDTH-1 downto 0));

    end component;

    function to_std_logicvector(a: integer; length: natural) return std_logic_vector IS
    begin
        return std_logic_vector(to_signed(a,length));
    end;


    procedure behave_alu(a: integer; b: integer; ctrl: integer; q: out std_logic_vector(TB_WIDTH-1 downto 0); cout: out std_logic) is
        variable ret: std_logic_vector(TB_WIDTH downto 0);
    begin
        case ctrl is
        when 0 => ret := to_std_logicvector(a+b, TB_WIDTH+1);
        when 1 => ret := to_std_logicvector(a-b,TB_WIDTH+1);
            ret(TB_WIDTH):= not ret(TB_WIDTH);
        when 2 => ret := '0' & (to_std_logicvector(a,TB_WIDTH) nand to_std_logicvector(b,TB_WIDTH));
        when 3 => ret := '0' & (to_std_logicvector(a,TB_WIDTH) nor to_std_logicvector(b,TB_WIDTH));
        when OTHERS =>
            assert false
            report "ctrl out of range, testbench error"
            severity error;
        end case;
        q := ret(TB_WIDTH-1 downto 0);
        cout := ret(TB_WIDTH);
    end;

    begin process
        variable res: std_logic_vector ( TB_WIDTH-1 downto 0);
        variable c: std_logic;
    begin
        for i in 0 to TB_WIDTH-1 loop
            a <= to_std_logicvector(i,TB_WIDTH);
            for j in 0 to TB_WIDTH loop
                b <= to_std_logicvector(j,TB_WIDTH);
                for k in 0 to 1 loop
                    ctrl<= to_std_logicvector(k,3)(1 downto 0);
                    wait for 10 ns;
                    behave_alu(i,j,k,res,c);
                    assert q = res
                    report "wrong result from ALU:" & integer'image(to_integer(unsigned(res))) & " a:" & integer'image(to_integer(unsigned(a))) & " b:" & integer'image(to_integer(unsigned(b))) & " ctrl:" & integer'image(to_integer(unsigned(ctrl)))
                    severity warning;
                    assert cout = c
                    report "wrong carry from ALU:"  & std_logic'image(cout) & " expected:" & std_logic'image(c) & " a:" & integer'image(to_integer(unsigned(a))) & " b:" & integer'image(to_integer(unsigned(b))) & " ctrl:" & integer'image(to_integer(unsigned(ctrl)))
                    severity warning;
                end loop;
            end loop;
        end loop;
        report "ALU testbench finished";
        wait;
    end process;

    uut: alu port map (a, b, cin, ctrl, cout, q);
end behavioral;
