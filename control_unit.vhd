library ieee;
use ieee.std_logic_1164.all;

entity control_unit is
	port(
		i_alu_op : in std_ulogic_vector(1 downto 0);
		i_opcode : in std_ulogic_vector(5 downto 0);
		o_control_bus : out std_ulogic_vector(8 downto 0));
end control_unit;

architecture rtl of control_unit is 
begin
	crtl_unit : process(all)
	begin
		case (i_opcode) is
			when "000000" =>		--R-format
				o_control_bus <= "011000010";
			when "100011" =>		--LW
				o_control_bus <= "110100100";
			when "101011" =>		--SW
				o_control_bus <= "00X101X00";
			when "000100" =>		--BEQ
				o_control_bus <= "00X010X01";
			when "000101" =>		--BNE
				o_control_bus <= "00X010X01";
			when others =>
				o_control_bus <= "XXXXXXXXX";
		end case;
	end process; -- crtl_unit
end rtl;