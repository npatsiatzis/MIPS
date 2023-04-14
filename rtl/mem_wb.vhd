library ieee;
use ieee.std_logic_1164.all;

entity mem_wb is 
	port(
		i_clk : in std_ulogic;
		i_rst : in std_ulogic;
		i_control_bus : in std_ulogic_vector(8 downto 0);
		i_dmem_data : in std_ulogic_vector(31 downto 0);
		i_alu_out : in std_ulogic_vector(31 downto 0);
		i_reg_write_addr : in std_ulogic_vector(4 downto 0);
		i_instr : in std_ulogic_vector(31 downto 0);

		o_control_bus : out std_ulogic_vector(8 downto 0);
		o_dmem_data : out std_ulogic_vector(31 downto 0);
		o_alu_out : out std_ulogic_vector(31 downto 0);
		o_reg_write_addr : out std_ulogic_vector(4 downto 0);
		o_instr : out std_ulogic_vector(31 downto 0));
end mem_wb;

architecture rtl of mem_wb is
begin
	mem_wb : process(i_clk)
	begin
		if(rising_edge(i_clk)) then
			if(i_rst = '1') then
				o_control_bus <= (others => '0');
				o_dmem_data <= (others => '0');
				o_alu_out <= (others => '0');
				o_reg_write_addr <= (others => '0');
				o_instr <= (others => '0');

			else
				o_control_bus <= i_control_bus;
				o_dmem_data <= i_dmem_data;
				o_alu_out <= i_alu_out;
				o_reg_write_addr <= i_reg_write_addr;
				o_instr <= i_instr;
			end if;
		end if;
	end process; -- mem_wb
end rtl;