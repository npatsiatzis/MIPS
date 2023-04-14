library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity shift2 is 
	port(
	i_data : in std_ulogic_vector(31 downto 0);
	o_shifted : out std_ulogic_vector(31 downto 0));
end shift2;

architecture rtl of shift2 is
begin
	o_shifted <= std_ulogic_vector(shift_left(unsigned(i_data),2));
end rtl;