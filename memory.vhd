--Single Port Block RAM in Write-First Mode
--The following is a low latency design(1 clock cycle). To increase
--performance, the latency can be increased by 1 clock cycle by using an 
--output register, to improve clock-to-out timing.


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity memory is
	generic(
		g_width : natural :=8;
		g_depth : natural :=4);
	port(
		i_clk : in std_ulogic;
		i_en : in std_ulogic;
		i_we : in std_ulogic;
		i_addr : in std_ulogic_vector(g_depth -1 downto 0);
		i_data : in std_ulogic_vector(g_width -1 downto 0);
		o_data : out std_ulogic_vector(g_width -1 downto 0));
end memory;

architecture rtl of memory is
	type ram_type is array(2**g_depth -1 downto 0) of std_ulogic_vector(g_width -1 downto 0);
	signal mem : ram_type:=(others => (others => '0'));
begin
	write_2_mem : process(i_clk)
	begin
		if(rising_edge(i_clk)) then
			if(i_en = '1') then
				if(i_we = '1') then
					mem(to_integer(unsigned(i_addr))) <= i_data;
					o_data <= i_data;
				else
					o_data <= mem(to_integer(unsigned(i_addr)));
				end if;
			end if;
		end if;
	end process; -- write_2_mem
end rtl;