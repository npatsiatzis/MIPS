library ieee;
use ieee.std_logic_1164.all;

entity hazard_detection_unit is 
	port(
		i_id_ex_mem_read : in std_ulogic;
		i_ex_mem_mem_read : in std_ulogic;
		i_id_ex_instr : in std_logic_vector(31 downto 0);
		i_id_ex_rt : in std_logic_vector(4 downto 0);
		i_if_id_instr : in std_logic_vector(31 downto 0);
		o_hold_PC : out std_ulogic;
		o_hold_if_id : out std_ulogic;
		o_mux_sel : out std_ulogic);
end hazard_detection_unit;

architecture rtl of hazard_detection_unit is
begin


	hazard_unit : process(i_id_ex_mem_read,i_id_ex_rt,i_if_id_instr,i_id_ex_instr)
		variable v_hold_PC : std_ulogic := '0';
		variable v_hold_if_id : std_ulogic := '0';
		variable v_hold_2_cycles : std_logic_vector(2 downto 0) := "000";
	begin
		if(i_id_ex_mem_read = '1' and v_hold_PC = '0' and v_hold_if_id = '0') then
			
			if(v_hold_2_cycles = "000" and i_id_ex_instr(31 downto 26) = "100011" and i_if_id_instr(31 downto 26) = "000100" and (i_id_ex_rt = i_if_id_instr(25 downto 21) or i_id_ex_rt = i_if_id_instr(20 downto 15))) then
				v_hold_2_cycles := "011";
			elsif(v_hold_2_cycles = "000" and  (i_id_ex_rt = i_if_id_instr(25 downto 21) or i_id_ex_rt = i_if_id_instr(20 downto 15))) then
				v_hold_2_cycles := "001";
			end if;		
		else
			v_hold_PC := '0';
			v_hold_if_id := '0';
			o_mux_sel <= '0';
		end if;
		
		v_hold_if_id := v_hold_2_cycles(0);
		o_hold_if_id <= v_hold_if_id;

		v_hold_2_cycles := '0' & v_hold_2_cycles(2 downto 1);

		v_hold_PC := v_hold_2_cycles(0);
		o_hold_PC <= v_hold_PC;

		o_mux_sel <= v_hold_if_id;

	end process; -- hazard_unit
end rtl;