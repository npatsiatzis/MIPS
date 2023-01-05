library ieee;
use ieee.std_logic_1164.all;

entity if_id is 
	port(
		i_clk : in std_ulogic;
		i_rst : in std_ulogic;
		i_we : in std_ulogic;
		i_flush : in std_ulogic;
		i_PC : in std_ulogic_vector(31 downto 0);
		i_instr : in std_ulogic_vector(31 downto 0);

		o_PC : out std_ulogic_vector(31 downto 0);
		o_instr : out std_ulogic_vector(31 downto 0));
end if_id;

architecture rtl of if_id is 
begin
	if_id_pipeline : process(i_clk)
	begin
		if(rising_edge(i_clk)) then
			if(i_rst = '1') then
				o_PC <= (others => '0');
				o_instr <= (others => '0');
			else
				if(i_flush = '1') then
					o_PC <= i_PC;
					o_instr <= (others => '0');
				elsif(i_we = '1') then
					o_PC <= i_PC;
					o_instr <= i_instr;
				end if;
			end if;
		end if;
	end process; -- if_id_pipeline
end rtl;