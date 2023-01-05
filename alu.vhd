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
		i_A : in std_ulogic_vector(g_width -1 downto 0);		--operand A
		i_B : in std_ulogic_vector(g_width -1 downto 0);		--operand B
		i_op : in std_ulogic_vector(3 downto 0);				--alu operation
		o_zero : out std_ulogic;								--alu result is zero
		o_out : out std_ulogic_vector(g_width -1 downto 0)); 	--alu result
end alu;

architecture rtl of alu is 
	signal unsigned_A : unsigned(g_width -1 downto 0);
	signal unsigned_B : unsigned(g_width -1 downto 0);
	signal w_result : unsigned(g_width -1 downto 0);
begin

	unsigned_A <= unsigned(i_A);
	unsigned_B <= unsigned(i_B);

	o_zero <= '1' when w_result = 0 else '0';
	o_out <= std_ulogic_vector(w_result);

	alu_ops : process(all)
	begin
		case(i_op) is
			when "0000" => 
				w_result <= (unsigned_A and unsigned_B);
			when "0001" => 
				w_result <= (unsigned_A or unsigned_B);
			when "0010" => 
				w_result <= unsigned_A + unsigned_B;
			when "0110" => 
				w_result <= unsigned_A - unsigned_B;
			when "0111" =>
				if(unsigned_A < unsigned_B) then
					w_result <= to_unsigned(1,g_width);
				else
					w_result <= to_unsigned(0,g_width);
				end if; 
			when "1100" => 
				w_result <= unsigned_A nor unsigned_B;
			when others =>
				w_result <= (others => '0');
		end case;
	end process; -- alu_ops
end rtl;