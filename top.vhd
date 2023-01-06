--MIPS-32; 32 bit architecture
--registers, ALU, instructions, data and address are 32-bit
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top is
	port(
		i_clk : in std_ulogic;
		i_rst : in std_ulogic;
		i_PC : in std_ulogic_vector(31 downto 0));
end top;

architecture rtl of top is
	signal w_PC_adder_out : std_ulogic_vector(i_PC'range);
	signal w_shift_out : std_ulogic_vector(i_PC'range);
	signal w_branch_add_out : std_ulogic_vector(i_PC'range);
	signal w_sign_extend_out : std_ulogic_vector(i_PC'range);
	signal w_curr_instr : std_ulogic_vector(i_PC'range);
	
	signal w_PC : std_ulogic_vector(i_PC'range);
	signal w_PC_final : std_ulogic_vector(i_PC'range);
	signal r_PC : std_ulogic_vector(i_PC'range);
	signal w_j_immediate : std_ulogic_vector(i_PC'range);

	signal w_control_bus : std_ulogic_vector(8 downto 0);
	signal w_alu_op : std_ulogic_vector(1 downto 0);
	signal w_jump : std_ulogic;
	--when asserted : memory is read
	--when de-asserted :  none
	alias w_mem_read : std_ulogic is w_control_bus(8);
	--when asserted : destination register is written with value on write_data
	--when de-asserted : none
	alias w_reg_write : std_ulogic is w_control_bus(7);
	--when asserted : the destination register comes from rd
	--when de-asserted : the destination register comes from rt
	alias w_reg_dst  : std_ulogic is w_control_bus(6);
	--when asserted : 2nd alu operand is the sign extended, lower 16 bit of the instruction
	--when de-asserted : 2nd alu operand comes from read_data_B
	alias w_alu_src  : std_ulogic is w_control_bus(5);
	--when asserted : PC is replaced by the branch target address
	--when de-asserted : PC is replaced by PC +4
	alias w_branch : std_ulogic is w_control_bus(4);
	--when asserted : memory is written
	--when de-asserted : none
	alias w_mem_write : std_ulogic is w_control_bus(3);
	--when asserted :  the value to the regsiter input comes from the data memory
	--when de-asserted : the value to the regsiter input comes from the alu
	alias w_mem_to_reg : std_ulogic is w_control_bus(2);


	signal w_alu_control : std_ulogic_vector(3 downto 0);

	signal w_reg_write_addr : std_ulogic_vector(4 downto 0);

	signal w_reg_file_data : std_ulogic_vector (i_PC'range);
	signal w_reg_rdataA : std_ulogic_vector(i_PC'range);
	signal w_reg_rdataB : std_ulogic_vector(i_PC'range);

	signal w_alu_inB : std_ulogic_vector(i_PC'range);

	signal w_alu_zero : std_ulogic;

	signal w_alu_out : std_ulogic_vector(i_PC'range);

	signal w_data_mem_out : std_ulogic_vector(i_PC'range);

	signal w_mux_bne : std_ulogic;

	signal w_PC_mux : std_ulogic;

	signal w_if_id_PC : std_ulogic_vector(i_PC'range);
	signal w_if_id_instr : std_ulogic_vector(i_PC'range);

	signal w_id_ex_control_bus : std_ulogic_vector(8 downto 0);
	signal w_id_ex_PC : std_ulogic_vector(i_PC'range);
	signal w_id_ex_reg_dataA : std_ulogic_vector(i_PC'range);
	signal w_id_ex_reg_dataB : std_ulogic_vector(i_PC'range);
	signal w_id_ex_sign_extend : std_ulogic_vector(i_PC'range);
	signal w_id_ex_rt : std_ulogic_vector(4 downto 0);
	signal w_id_ex_rd : std_ulogic_vector(4 downto 0);
	signal w_id_ex_curr_instr : std_ulogic_vector(31 downto 0);
	signal w_id_ex_jump : std_ulogic;

	signal id_ex_control_bus : std_ulogic_vector(8 downto 0);
	signal id_ex_PC : std_ulogic_vector(i_PC'range);
	signal id_ex_rdataA : std_ulogic_vector(i_PC'range);
	signal id_ex_rdataB : std_ulogic_vector(i_PC'range);
	signal id_ex_sign_extend : std_ulogic_vector(31 downto 0); 
	signal id_ex_rt : std_ulogic_vector(4 downto 0);
	signal id_ex_rd : std_ulogic_vector(4 downto 0);
	signal id_ex_instr : std_ulogic_vector(i_PC'range);
	signal id_ex_jump : std_ulogic;

	signal w_ex_mem_control_bus : std_ulogic_vector(8 downto 0);
	signal w_ex_mem_adder : std_ulogic_vector(i_PC'range);
	signal w_ex_mem_alu_zero : std_ulogic;
	signal w_ex_mem_alu_out : std_ulogic_vector(i_PC'range);
	signal w_ex_mem_reg_dataB : std_ulogic_vector(i_PC'range);
	signal w_ex_mem_reg_write_addr : std_ulogic_vector(4 downto 0);
	signal w_ex_mem_curr_instr : std_ulogic_vector(i_PC'range);
	signal w_ex_mem_jump : std_ulogic;

	signal w_mem_wb_control_bus : std_ulogic_vector(8 downto 0);
	signal w_mem_wb_dmem_data : std_ulogic_vector(i_PC'range);
	signal w_mem_wb_alu_out : std_ulogic_vector(i_PC'range);
	signal w_mem_wb_reg_write_addr : std_ulogic_vector(4 downto 0);
	signal w_mem_wb_curr_instr : std_ulogic_vector(i_PC'range);

	signal w_hold_PC : std_ulogic;
	signal w_hold_if_id : std_ulogic;
	signal w_flush_mux_sel : std_ulogic;


	signal w_umux_sel : std_ulogic_vector(1 downto 0);
	signal w_lmux_sel : std_ulogic_vector(1 downto 0);
	signal w_comp_mux1_sel : std_ulogic_vector(1 downto 0);
	signal w_comp_mux2_sel : std_ulogic_vector(1 downto 0);

	signal fwdA_out : std_ulogic_vector(i_PC'range);
	signal fwdB_out : std_ulogic_vector(i_PC'range);

	signal w_compA : std_ulogic_vector(i_PC'range);
	signal w_compB : std_ulogic_vector(i_PC'range);
	signal w_comp_equal : std_ulogic;

	signal w_flush_if_id : std_ulogic;

	signal w_flush_from_ex : std_ulogic;
	signal branch_add_out : std_ulogic_vector(i_PC'range);
	signal r_branch_add_out : std_ulogic_vector(i_PC'range);
begin

	if_id_inst : entity work.if_id(rtl)
	port map(
		i_clk => i_clk,
		i_rst => i_rst,
		i_we => not w_hold_if_id,
		i_flush => w_flush_if_id,
		i_PC => w_PC_adder_out,
		i_instr => w_curr_instr,
		i_branch_add_out => w_branch_add_out,

		o_PC => w_if_id_PC,
		o_instr => w_if_id_instr,
		o_branch_add_out => r_branch_add_out);


	id_ex_inst : entity work.id_ex(rtl)
	port map(
		i_clk => i_clk,
		i_rst => i_rst,
		i_control_bus => id_ex_control_bus,
		i_PC => id_ex_PC,
		i_reg_dataA => id_ex_rdataA,
		i_reg_dataB => id_ex_rdataB,
		i_sign_extend =>id_ex_sign_extend,
		i_rt => id_ex_rt,
		i_rd =>id_ex_rd,
		i_instr =>id_ex_instr,
		i_jump =>id_ex_jump,

		o_control_bus => w_id_ex_control_bus,
		o_PC =>w_id_ex_PC,
		o_reg_dataA =>w_id_ex_reg_dataA,
		o_reg_dataB =>w_id_ex_reg_dataB,
		o_sign_extend =>w_id_ex_sign_extend,
		o_rt =>w_id_ex_rt,
		o_rd =>w_id_ex_rd,
		o_instr => w_id_ex_curr_instr,
		o_jump => w_id_ex_jump);


	ex_mem_inst : entity work.ex_mem(rtl)
	port map(
		i_clk => i_clk,
		i_rst => i_rst,
		i_control_bus =>w_id_ex_control_bus,
		i_adder => (others => '0'),
		i_alu_zero =>w_alu_zero,
		i_alu_out =>w_alu_out,
		i_reg_dataB =>w_id_ex_reg_dataB,
		i_reg_write_addr =>w_reg_write_addr,
		i_instr => w_id_ex_curr_instr,
		i_jump => w_id_ex_jump,

		o_control_bus =>w_ex_mem_control_bus,
		o_adder =>w_ex_mem_adder,
		o_alu_zero =>w_ex_mem_alu_zero,
		o_alu_out =>w_ex_mem_alu_out,
		o_reg_dataB =>w_ex_mem_reg_dataB,
		o_reg_write_addr =>w_ex_mem_reg_write_addr,
		o_instr => w_ex_mem_curr_instr,
		o_jump => w_ex_mem_jump);

	mem_wb_inst : entity work.mem_wb(rtl)
	port map(
		i_clk => i_clk,
		i_rst => i_rst,
		i_control_bus=> w_ex_mem_control_bus,
		i_dmem_data =>w_data_mem_out,
		i_alu_out => w_ex_mem_alu_out,
		i_reg_write_addr =>w_ex_mem_reg_write_addr,
		i_instr =>w_ex_mem_curr_instr,

		o_control_bus=>w_mem_wb_control_bus,
		o_dmem_data =>w_mem_wb_dmem_data,
		o_alu_out =>w_mem_wb_alu_out,
		o_reg_write_addr=>w_mem_wb_reg_write_addr,
		o_instr =>w_mem_wb_curr_instr);

	---------------------------INSTRUCTION FETCH------------------------
	adder32_PC : entity work.adder_32(rtl)
	port map(
		i_A => r_PC,
		i_B => std_ulogic_vector(to_unsigned(1,r_PC'length)),
		o_result => w_PC_adder_out);

	memory_InstrMem : entity work.i_memory(rtl)
	generic map(
		g_width =>32,
		g_depth =>12)
	port map(
		i_clk => i_clk,
		i_en => '1',
		i_we => '0',
		i_addr => r_PC,
		i_data => (others => '0'),
		o_data => w_curr_instr);

	branch_add_out <= r_branch_add_out when w_alu_zero = '1' and w_id_ex_control_bus(4) = '1' and w_mem_wb_control_bus(8) = '1' 
	else w_branch_add_out;

	mux2_32_PC : entity work.mux2(rtl)
	generic map(
		g_width => 32)
	port map(
		i_A =>w_PC_adder_out,
		i_B=>branch_add_out,
		--i_B=>w_branch_add_out,
		i_sel=>w_PC_mux,
		o_out=>w_PC);

	w_j_immediate  <= std_ulogic_vector(resize(unsigned(w_if_id_instr(25 downto 0)),32));

	mux2_32_PC_final : entity work.mux2(rtl)
	generic map(
		g_width => 32)
	port map(
		i_A =>w_PC,
		i_B=> w_j_immediate,
		i_sel=>w_jump,
		o_out=>w_PC_final);

	w_flush_if_id <= w_jump or w_PC_mux;
	----------------------INSTRUCTION DECODE------------------------------

	sign_extend : entity work.sign_extend(rtl)
	port map(
		i_data =>w_if_id_instr(15 downto 0),		
		o_data => w_sign_extend_out);

	control_unit : entity work.control_unit(rtl)
	port map(
		i_opcode =>w_if_id_instr(31 downto 26),
		o_alu_op => w_alu_op,
		o_jump => w_jump,							
		o_control_bus=> w_control_bus);

	reg_file : entity work.reg_file(rtl)
	generic map(
		g_width => 32,
		g_depth => 5)
	port map(
		i_clk =>i_clk,
		i_rst =>i_rst,
		i_we => w_mem_wb_control_bus(7),			
		i_waddr => w_mem_wb_reg_write_addr,
		i_raddr_A => w_if_id_instr(25 downto 21), 
		i_raddr_B => w_if_id_instr(20 downto 16),
		i_data => w_reg_file_data,
		o_data_A => w_reg_rdataA,
		o_data_B => w_reg_rdataB);	


	id_ex_flush_mux : process(all)
	begin
		if(w_flush_mux_sel = '1' or w_flush_from_ex = '1') then
			id_ex_control_bus <= (others => '0');
			id_ex_PC <= (others => '0');
			id_ex_rdataA <= (others => '0');
			id_ex_rdataB <= (others => '0');
			id_ex_sign_extend <= (others => '0');
			id_ex_rt <= (others => '0');
			id_ex_rd <= (others => '0');
			id_ex_instr <= (others => '0');
			id_ex_jump <= '0';
		else
			id_ex_control_bus  <= w_control_bus;
			id_ex_PC <= w_if_id_PC;
			id_ex_rdataA <= w_reg_rdataA;
			id_ex_rdataB <= w_reg_rdataB;
			id_ex_sign_extend <= w_sign_extend_out;
			id_ex_rt <= w_if_id_instr(20 downto 16);
			id_ex_rd <= w_if_id_instr(15 downto 11);
			id_ex_instr <= w_if_id_instr;
			id_ex_jump <= w_jump;
		end if;
	end process; -- id_ex_flush_mux


	hazard_detection : entity work.hazard_detection_unit(rtl)
	port map(
		i_id_ex_mem_read => w_id_ex_control_bus(8),
		i_ex_mem_mem_read => w_ex_mem_control_bus(8),
		i_id_ex_rt => w_id_ex_curr_instr(20 downto 16),
		i_if_id_instr => w_if_id_instr,
		o_hold_PC => w_hold_PC,
		o_hold_if_id => w_hold_if_id,
		o_mux_sel => w_flush_mux_sel);


	adder32_branch : entity work.adder_32(rtl)
	port map(
		i_A => w_if_id_PC,
		i_B => w_sign_extend_out,				
		o_result => w_branch_add_out);

	comp3_A : process(all)
	begin
		if(w_comp_mux1_sel = "00") then
			w_compA <= w_reg_rdataA;
		elsif(w_comp_mux1_sel = "01") then
			w_compA <= w_ex_mem_alu_out;
		elsif(w_comp_mux1_sel = "10") then
			w_compA <= w_reg_file_data;
		end if;
	end process; -- comp3_A

	comp3_B : process(all)
	begin
		if(w_comp_mux2_sel = "00") then
			w_compB <= w_reg_rdataB;
		elsif(w_comp_mux2_sel = "01") then
			w_compB <= w_ex_mem_alu_out;
		elsif(w_comp_mux2_sel = "10") then
			w_compB <= w_reg_file_data;
		end if;
	end process; -- comp3_B

	w_comp_equal <= '1' when (w_compA = w_compB) else '0';
	w_flush_from_ex <= '1' when (w_alu_zero xor  w_id_ex_curr_instr(26)) = '1' and w_id_ex_control_bus(4) = '1' and w_mem_wb_control_bus(8) = '1' 
	else '0';
	w_PC_mux <=  w_alu_zero xor  w_id_ex_curr_instr(26) when (w_id_ex_control_bus(4) = '1' and w_mem_wb_control_bus(8) = '1')
	else w_control_bus(4) and w_comp_equal;
	--------------------EXECUTE-------------------------------

	alu_decoder : entity work.alu_decoder(rtl)
	port map(
		i_alu_op => w_id_ex_control_bus(1 downto 0),
		i_func => w_id_ex_curr_instr(5 downto 0),
		o_alu_control => w_alu_control);

	mux2_5_reg_write_addr : entity work.mux2(rtl)
	generic map(
		g_width => 5)
	port map(
		i_A => w_id_ex_curr_instr(20 downto 16),
		i_B => w_id_ex_curr_instr(15 downto 11),
		i_sel => w_id_ex_control_bus(6),
		o_out => w_reg_write_addr);

	mux2_32_alu_inB : entity work.mux2(rtl)
	generic map(
		g_width => 32)
	port map(
		i_A => fwdB_out,
		i_B=> w_id_ex_sign_extend,
		i_sel=>w_id_ex_control_bus(5),
		o_out=> w_alu_inB);

	alu : entity work.alu(rtl) 
	generic map(
		g_width => 32)
	port map(
		i_A => fwdA_out,
		i_B => w_alu_inB,
		i_op => w_alu_control,
		o_zero => w_alu_zero,
		o_out => w_alu_out);


	mux_fwdA : process(all)
	begin
		if(w_umux_sel = "00") then
			fwdA_out <= w_id_ex_reg_dataA;
		elsif(w_umux_sel = "01") then
			fwdA_out <= w_reg_file_data;
		elsif(w_umux_sel = "10") then
			fwdA_out <= w_ex_mem_alu_out;
		end if;
	end process; -- mux_fwdA

	mux_fwdB : process(all)
	begin
		if(w_lmux_sel = "00") then
			fwdB_out <= w_id_ex_reg_dataB;
		elsif(w_lmux_sel = "01") then
			fwdB_out <= w_reg_file_data;
		elsif(w_lmux_sel = "10") then
			fwdB_out <= w_ex_mem_alu_out;
		end if;
	end process; -- mux_fwdA

	forwarding : entity work.forwarding_unit(rtl)
	port map(
		i_ex_mem_reg_write => w_ex_mem_control_bus(7),
		i_mem_wb_reg_write => w_mem_wb_control_bus(7),
		i_ex_mem_write_reg => w_ex_mem_reg_write_addr,
		--i_ex_mem_write_reg => w_ex_mem_curr_instr(15 downto 11),
		i_mem_wb_write_reg => w_mem_wb_reg_write_addr,
		--i_mem_wb_write_reg => w_mem_wb_curr_instr(15 downto 11),
		i_id_ex_rs => w_id_ex_curr_instr(25 downto 21),
		i_id_ex_rt => w_id_ex_curr_instr(20 downto 16),
		o_umux_sel => w_umux_sel,
		o_lmux_sel => w_lmux_sel,
		o_comp_mux1_sel => w_comp_mux1_sel,
		o_comp_mux2_sel => w_comp_mux2_sel);

	----------memory----------------


	memory_DataMem : entity work.d_memory(rtl)
	generic map(
		g_width =>32,
		g_depth =>12)
	port map(
		i_clk => i_clk,
		i_en => '1',
		i_we => w_ex_mem_control_bus(3),
		i_addr => w_ex_mem_alu_out,
		i_data => w_ex_mem_reg_dataB,
		o_data => w_data_mem_out);
	---------------WB----------------------------

	mux2_32_reg_write_data : entity work.mux2(rtl)
	generic map(
		g_width => 32)
	port map(
		i_A => w_mem_wb_alu_out,
		i_B => w_mem_wb_dmem_data,
		i_sel => w_mem_wb_control_bus(2),
		o_out => w_reg_file_data);


	manage_PC : process(i_clk)
	begin
		if(rising_edge(i_clk)) then
			if(i_rst = '1') then
				r_PC <= i_PC;
			elsif(w_hold_PC = '0') then
				r_PC <= w_PC_final;
			end if;
		end if;
	end process; -- manage_PC

end rtl;