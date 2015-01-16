
package open_collector is
    type opc_ulogic is (
        'X',  -- Forcing  Unknown
        '0',  -- Forcing  0
        '1',  -- Forcing  1
        'Z',  -- High Impedance   
        'H'   -- Weak     1       
    );
    type opc_ulogic_vector is array ( natural range <> ) of opc_ulogic;
    function resolved ( s : opc_ulogic_vector ) return opc_ulogic;
    subtype opc_logic IS resolved opc_ulogic;
    type opc_logic_vector is array ( natural range <> ) of opc_logic;
end open_collector;

package body open_collector IS
    type opc_table is array(opc_ulogic, opc_ulogic) of opc_ulogic;

    constant resolution_table : opc_table := (
            ( 'X', 'X', 'X', 'X', 'X' ), -- | X |
            ( 'X', '0', '0', '0', '0' ), -- | 0 |
            ( 'X', '0', '1', '1', '1' ), -- | 1 |
            ( 'X', '0', '1', 'Z', 'H' ), -- | Z |
            ( 'X', '0', '1', 'H', 'H' )  -- | H |
    );
        
    function resolved ( s : opc_ulogic_vector ) return opc_ulogic is
        variable result : opc_ulogic := 'Z';  -- weakest state default
    begin
        if (s'length = 1) then
            return s(s'low);
        else
            for i in s'range loop
                result := resolution_table(result, s(i));
            end loop;
        end if;
        return result;
    end resolved;
end open_collector;
