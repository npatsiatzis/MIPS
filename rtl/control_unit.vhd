--Select the operations to perform; control the flow of data( mux's select inputs); enable 
--inputs of memeory and register file. 

library ieee;
use ieee.std_logic_1164.all;

entity control_unit is
	port(
		i_opcode : in std_ulogic_vector(5 downto 0);
		o_alu_op : out std_ulogic_vector(1 downto 0);
		o_jump : out std_ulogic;
		o_control_bus : out std_ulogic_vector(8 downto 0));
end control_unit;

architecture rtl of control_unit is 
begin

	o_alu_op <= o_control_bus(1 downto 0);

	crtl_unit : process(all)
	begin
		o_jump <= '0';
		case (i_opcode) is
			when "000000" =>		--R-format		R-format : add,sub,and...
				o_control_bus <= "011000010";	  --I-format : sw,lw,slt,beq,bne
			when "100011" =>		--LW
				o_control_bus <= "110100100";
			when "101011" =>		--SW
				o_control_bus <= "00X101X00";
			when "000100" =>		--BEQ
				o_control_bus <= "00X010X01";
		when "000101" =>		--BNE
				o_control_bus <= "00X010X01";
		when "000010" => 		--j
				o_control_bus <= "X01X1XXXX";
				o_jump <= '1';
			when others =>
				o_control_bus <= "XXXXXXXXX";
				o_jump <= '0';
		end case;
	end process; -- crtl_unit
end rtl;