--32-bit addder to help with the ProgramCounter (PC)

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adder_32 is
	port(
		i_A : in std_ulogic_vector(31 downto 0);
		i_B : in std_ulogic_vector(31 downto 0);
		o_result : out std_ulogic_vector(31 downto 0));
end adder_32;

architecture rtl of adder_32 is
begin
	add_32 : process(all)
	begin
		o_result <= std_ulogic_vector(unsigned(i_A) + unsigned(i_B));
	end process; -- add_32
end rtl;