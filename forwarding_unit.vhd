library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity forwarding_unit is 
	port(
		i_ex_mem_reg_write : in std_ulogic;
		i_mem_wb_reg_write : in std_ulogic;
		i_ex_mem_write_reg : in std_ulogic_vector(4 downto 0); 	--destination register (rd)
		i_mem_wb_write_reg : in std_ulogic_vector(4 downto 0);
		i_id_ex_rs : in std_ulogic_vector(4 downto 0);
		i_id_ex_rt : in std_ulogic_vector(4 downto 0);
		o_umux_sel : out std_ulogic_vector(1 downto 0);
		o_lmux_sel : out std_ulogic_vector(1 downto 0);
		o_comp_mux1_sel : out std_ulogic_vector(1 downto 0);
		o_comp_mux2_sel : out std_ulogic_vector(1 downto 0));
end forwarding_unit;

architecture rtl of forwarding_unit is 
begin
	forwarding : process(all)
	begin
		if(i_ex_mem_reg_write = '1' and unsigned(i_ex_mem_write_reg) /= 0 and unsigned(i_ex_mem_write_reg) = unsigned(i_id_ex_rs)) then
				o_umux_sel <= "10";
				o_comp_mux1_sel <= "01";
		
		elsif (i_mem_wb_reg_write  = '1' and unsigned(i_mem_wb_write_reg) /= 0 and unsigned(i_mem_wb_write_reg) = unsigned(i_id_ex_rs)) then
				o_umux_sel <= "01";
				o_comp_mux1_sel <= "10";
		else
				o_umux_sel <= "00";
				o_comp_mux1_sel <= "00";	
		end if;

		if (i_ex_mem_reg_write = '1' and unsigned(i_ex_mem_write_reg) /= 0 and unsigned(i_ex_mem_write_reg) = unsigned(i_id_ex_rt)) then
				o_lmux_sel <= "10";
				o_comp_mux2_sel <= "01";

		elsif (i_mem_wb_reg_write  = '1' and unsigned(i_mem_wb_write_reg) /= 0 and unsigned(i_mem_wb_write_reg) = unsigned(i_id_ex_rt)) then
				o_lmux_sel <= "01";
				o_comp_mux2_sel <= "10";
		else
				o_lmux_sel <= "00";
				o_comp_mux2_sel <= "00";
		end if;
		--if(i_ex_mem_reg_write = '1' and unsigned(i_ex_mem_write_reg) /= 0) then	--fwd. mem to alu & mem to id
		--	if(unsigned(i_ex_mem_write_reg) = unsigned(i_id_ex_rs)) then
		--		o_umux_sel <= "10";
		--		o_comp_mux1_sel <= "01";
		--	else
		--		o_umux_sel <= "00";
		--		o_comp_mux1_sel <= "00";
		--	end if;

		--	if(unsigned(i_ex_mem_write_reg) = unsigned(i_id_ex_rt)) then
		--		o_lmux_sel <= "10";
		--		o_comp_mux2_sel <= "01";
		--	else
		--		o_lmux_sel <= "00";
		--		o_comp_mux2_sel <= "00";
		--	end if;			

		--elsif(i_mem_wb_reg_write  = '1' and unsigned(i_mem_wb_write_reg) /= 0) then
		--	if(unsigned(i_mem_wb_write_reg) = unsigned(i_id_ex_rs)) then
		--	--if(unsigned(i_mem_wb_write_reg) = unsigned(i_id_ex_rs) and (unsigned(i_ex_mem_write_reg) /= unsigned(i_id_ex_rs) or i_ex_mem_reg_write = '0')) then
		--		o_umux_sel <= "01";
		--		o_comp_mux1_sel <= "10";
		--	else
		--		o_umux_sel <= "00";
		--		o_comp_mux1_sel <= "00";
		--	end if;
		--	if(unsigned(i_mem_wb_write_reg) = unsigned(i_id_ex_rt)) then
		--	--if(unsigned(i_mem_wb_write_reg) = unsigned(i_id_ex_rt) and (unsigned(i_ex_mem_write_reg) /= unsigned(i_id_ex_rt) or i_ex_mem_reg_write = '0')) then
		--		o_lmux_sel <= "01";
		--		o_comp_mux2_sel <= "10";
		--	else
		--		o_lmux_sel <= "00";
		--		o_comp_mux2_sel <= "00";
		--	end if;
		--else
		--	o_umux_sel <= "00";
		--	o_lmux_sel <= "00";
		--	o_comp_mux1_sel <= "00";
		--	o_comp_mux2_sel <= "00";
		--end if;
	end process; -- forwarding
end rtl;