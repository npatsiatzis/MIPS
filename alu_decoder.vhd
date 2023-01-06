--alu decoder for the 3 different instruction formats
library ieee;
use ieee.std_logic_1164.all;

entity alu_decoder is
	port(
		i_alu_op : in std_ulogic_vector(1 downto 0);			--instruction type(R,I,J)
		i_func : in std_ulogic_vector(5 downto 0);				--format function codes
		o_alu_control : out std_ulogic_vector(3 downto 0));
end alu_decoder;


architecture rtl of alu_decoder is
begin
	alu_decode : process(all)
	begin
		case(i_alu_op) is                           --alu operation to perform
			when "00" =>		--LW/SW 
				o_alu_control <= "0010";			--add

			when "01" =>		--BEQ/BNE 
				o_alu_control <= "0110";			--sub

			when "10" =>		--R-format (here, operation depends of the instrctuction's func field)
				case(i_func) is
					when "100000" => 
						o_alu_control <= "0010";	--add
					when "100010" => 			
						o_alu_control <= "0110";	--sub
					when "100100" => 
						o_alu_control <= "0000";	--and
					when "100101" => 
						o_alu_control <= "0001";	--or
					when "101010" => 
						o_alu_control <= "0111";	--slt
					when "100111" => 				
						o_alu_control <= "1100";	--nor
					when others =>
						o_alu_control <= (others => 'X');
				end case;
			when others =>
				o_alu_control <= (others => 'X');
		end case;
	end process; -- alu_decode
end rtl;