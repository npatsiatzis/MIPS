library ieee;
use ieee.std_logic_1164.all;


entity sign_extend is
	port(
		i_data : in std_ulogic_vector(15 downto 0);
		o_data : out std_ulogic_vector(31 downto 0));
end sign_extend;

architecture rtl of sign_extend is
begin
	o_data(15 downto 0) <= i_data;
	o_data(31 downto 16) <= (others => '1') when i_data(15) = '1' else (others => '0');	
end rtl;