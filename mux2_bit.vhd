library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

entity mux2_bit is
	generic(
		g_width : natural :=4);
	port(
		i_A : in std_ulogic;
		i_B : in std_ulogic;
		i_sel : in std_ulogic;
		o_out : out std_ulogic);
end mux2_bit;

architecture rtl of mux2_bit is
begin
	mux2_operation : process(all) 
	begin
		if(i_sel = '0') then
			o_out <= i_A;
		else 
			o_out <= i_B;
		end if;
	end process; -- mux2_operation
end rtl;