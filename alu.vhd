--ALU Inputs: i_A,i_B,i_op, Outputs: o_out,o_zero
--Operations :
--Bitwise AND (op :0)
--Bitwise OR (op :1)
--ADD (op :2)
--SUB (op :6)
--SLT (op :7)
--NOR (op :12)

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.numeric_std_unsigned.all;

entity alu is
	generic(
		g_width : natural :=4);
	port(
		i_A : in std_ulogic_vector(g_width -1 downto 0);
		i_B : in std_ulogic_vector(g_width -1 downto 0);
		i_op : in std_ulogic_vector(3 downto 0);
		o_zero : out std_ulogic;
		o_out : out std_ulogic_vector(g_width downto 0)); 
end alu;

architecture rtl of alu is 
	signal signed_A : signed(g_width -1 downto 0);
	signal signed_B : signed(g_width -1 downto 0);
	signal w_result : signed(g_width downto 0);
begin

	signed_A <= signed(i_A);
	signed_B <= signed(i_B);

	o_zero <= '1' when w_result = 0 else '0';
	o_out <= std_ulogic_vector(w_result);

	alu_ops : process(all)
	begin
		case(i_op) is
			when "0000" => 
				w_result <= '0' & (signed_A and signed_B);
			when "0001" => 
				w_result <= '0' & (signed_A or signed_B);
			when "0010" => 
				w_result <= resize(signed_A,g_width+1) + signed_B;
			when "0110" => 
				w_result <= resize(signed_A,g_width+1) - signed_B;
			when "0111" =>
				if(signed_A < signed_B) then
					w_result <= to_signed(1,g_width+1);
				else
					w_result <= to_signed(0,g_width+1);
				end if; 
			when "1100" => 
				w_result <= '0' &  not((signed_A or signed_B));
			when others =>
				w_result <= (others => 'X');
		end case;
	end process; -- alu_ops
end rtl;