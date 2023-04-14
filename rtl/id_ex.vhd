library ieee;
use ieee.std_logic_1164.all;

entity id_ex is 
	port(
		i_clk : in std_ulogic;
		i_rst : in std_ulogic;
		i_control_bus : in std_ulogic_vector(8 downto 0);
		i_PC : in std_ulogic_vector(31 downto 0);
		i_reg_dataA : in std_ulogic_vector(31 downto 0);
		i_reg_dataB : in std_ulogic_vector(31 downto 0);
		i_sign_extend : in std_ulogic_vector(31 downto 0);
		i_rt : in std_ulogic_vector(4 downto 0);
		i_rd : in std_ulogic_vector(4 downto 0);
		i_instr : in std_ulogic_vector(31 downto 0);
		i_jump : in std_ulogic;

		o_control_bus : out std_ulogic_vector(8 downto 0);
		o_PC : out std_ulogic_vector(31 downto 0);
		o_reg_dataA : out std_ulogic_vector(31 downto 0);
		o_reg_dataB : out std_ulogic_vector(31 downto 0);
		o_sign_extend : out std_ulogic_vector(31 downto 0);
		o_rt : out std_ulogic_vector(4 downto 0);
		o_rd : out std_ulogic_vector(4 downto 0);
		o_instr : out std_ulogic_vector(31 downto 0);
		o_jump : out std_ulogic);
end id_ex;

architecture rtl of id_ex is
begin
	id_ex_pipeline : process(i_clk)
	begin
		if(rising_edge(i_clk)) then
			if(i_rst = '1') then
				o_control_bus <= (others => '0');
				o_PC <= (others => '0');
				o_reg_dataA <= (others => '0');
				o_reg_dataB <= (others => '0');
				o_sign_extend <= (others => '0');
				o_rt <= (others => '0');
				o_rd <= (others => '0');
				o_instr <= (others => '0');
				o_jump <= '0';
			else
				o_control_bus <= i_control_bus;
				o_PC <= i_PC;
				o_reg_dataA <= i_reg_dataA;
				o_reg_dataB <= i_reg_dataB;
				o_sign_extend <= i_sign_extend;
				o_rt <= i_rt;
				o_rd <= i_rd;
				o_instr <= i_instr;
				o_jump <= i_jump;
			end if;
		end if;
	end process; -- id_ex_pipeline
end rtl;