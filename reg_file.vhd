library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reg_file is 
	generic(
		g_width : natural := 4;
		g_depth : natural := 4);
	port(
		i_clk : in std_ulogic;
		i_rst : in std_ulogic;
		
		i_we : in std_ulogic;
		i_waddr : in std_ulogic_vector(g_depth-1 downto 0);
		i_raddr_A : in std_ulogic_vector(g_depth-1 downto 0);
		i_raddr_B : in std_ulogic_vector(g_depth-1 downto 0);
		i_data : in std_ulogic_vector(g_width-1 downto 0);

		o_data_A : out std_ulogic_vector(g_width-1 downto 0);
		o_data_B : out std_ulogic_vector(g_width-1 downto 0));
end reg_file;

architecture rtl of reg_file is
	type t_regfile is array (0 to 2**g_depth-1) of std_ulogic_vector(g_width-1 downto 0);
	signal regfile : t_regfile;
begin
	regfile_operation : process(i_clk)
	begin
		if(rising_edge(i_clk)) then
			if(i_rst = '1') then
				regfile <= (others => (others => '0'));
			end if;
		else
			o_data_A <= regfile(to_integer(unsigned(i_raddr_A)));
			o_data_B <= regfile(to_integer(unsigned(i_raddr_B)));
			if(i_we = '1') then
				regfile(to_integer(unsigned(i_waddr))) <= i_data;
			end if;
		end if;
	end process; -- regfile_operation
end rtl;


