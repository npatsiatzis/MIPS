library ieee;
use ieee.std_logic_1164.all;

entity ex_mem is 
	port(
		i_clk : in std_ulogic;
		i_rst : in std_ulogic;
		i_control_bus : in std_ulogic_vector(8 downto 0);
		i_adder : in std_ulogic_vector(31 downto 0);
		i_alu_zero : in std_ulogic;
		i_alu_out : in std_ulogic_vector(31 downto 0);
		i_reg_dataB : in std_ulogic_vector(31 downto 0);
		i_reg_write_addr : in std_ulogic_vector(4 downto 0);
		i_instr : in std_ulogic_vector(31 downto 0);
		i_jump : in std_ulogic;

		o_control_bus : out std_ulogic_vector(8 downto 0);
		o_adder : out std_ulogic_vector(31 downto 0);
		o_alu_zero : out std_ulogic;
		o_alu_out : out std_ulogic_vector(31 downto 0);
		o_reg_dataB : out std_ulogic_vector(31 downto 0);
		o_reg_write_addr : out std_ulogic_vector(4 downto 0);
		o_instr : out std_ulogic_vector(31 downto 0);
		o_jump : out std_ulogic);
end ex_mem;

architecture rtl of ex_mem is 
begin

	ex_mem_pipeline : process(i_clk) 
	begin
		if(rising_edge(i_clk)) then
			if(i_rst = '1') then
				o_control_bus <= (others => '0');
				o_adder <= (others => '0');
				o_alu_zero <= '0';
				o_alu_out <= (others => '0');
				o_reg_dataB <= (others => '0');
				o_reg_write_addr <= (others => '0');
				o_instr <= (others => '0');
				o_jump <= '0';
			else
			o_control_bus <= i_control_bus;
			o_adder <= i_adder;
			o_alu_zero <= i_alu_zero;
			o_alu_out <= i_alu_out;
			o_reg_dataB <= i_reg_dataB;
			o_reg_write_addr <= i_reg_write_addr;
			o_instr <= i_instr;
			o_jump <= i_jump;
			end if;
		end if;
	end process; -- ex_mem_pipeline
end rtl;