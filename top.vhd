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
begin


	if_id_inst : entity work.if_id(rtl)
	port map(
		i_clk => i_clk,
		i_rst => i_rst,
		i_PC => w_PC_adder_out,
		i_instr => w_curr_instr,

		o_PC => w_if_id_PC,
		o_instr => w_if_id_instr);


	id_ex_inst : entity work.id_ex(rtl)
	port map(
		i_clk => i_clk,
		i_rst => i_rst,
		i_control_bus => w_control_bus,
		i_PC => w_if_id_PC,
		i_reg_dataA => w_reg_rdataA,
		i_reg_dataB => w_reg_rdataB,
		i_sign_extend => w_sign_extend_out,
		i_rt =>w_if_id_instr(20 downto 16),
		i_rd => w_if_id_instr(15 downto 11),
		i_instr =>w_if_id_instr,
		i_jump =>w_jump,

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
		i_adder => w_branch_add_out,
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

		o_control_bus=>w_mem_wb_control_bus,
		o_dmem_data =>w_mem_wb_dmem_data,
		o_alu_out =>w_mem_wb_alu_out,
		o_reg_write_addr=>w_mem_wb_reg_write_addr);


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


	mux2_32_PC : entity work.mux2(rtl)
	generic map(
		g_width => 32)
	port map(
		i_A =>w_PC_adder_out,
		i_B=>w_ex_mem_adder,
		i_sel=>w_PC_mux,
		o_out=>w_PC);

	w_j_immediate  <= std_ulogic_vector(resize(unsigned(w_ex_mem_curr_instr(25 downto 0)),32));

	mux2_32_PC_final : entity work.mux2(rtl)
	generic map(
		g_width => 32)
	port map(
		i_A =>w_PC,
		i_B=> w_j_immediate,
		i_sel=>w_ex_mem_jump,
		o_out=>w_PC_final);

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

	--------------------EXECUTE-------------------------------

	adder32_branch : entity work.adder_32(rtl)
	port map(
		i_A => w_id_ex_PC,
		i_B => w_id_ex_sign_extend,				
		o_result => w_branch_add_out);

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
		i_A => w_id_ex_reg_dataB,
		i_B=> w_id_ex_sign_extend,
		i_sel=>w_id_ex_control_bus(5),
		o_out=> w_alu_inB);

	alu : entity work.alu(rtl) 
	generic map(
		g_width => 32)
	port map(
		i_A => w_id_ex_reg_dataA,
		i_B => w_alu_inB,
		i_op => w_alu_control,
		o_zero => w_alu_zero,
		o_out => w_alu_out);

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

	mux2_1_bne : entity work.mux2_bit(rtl)
	generic map(
		g_width => 1)
	port map(
		i_A => w_ex_mem_alu_zero,
		i_B => not w_ex_mem_alu_zero,
		i_sel => w_ex_mem_curr_instr(26),
		o_out => w_mux_bne);


	w_PC_mux <= w_ex_mem_control_bus(4) and w_mux_bne;

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
			else
				r_PC <= w_PC_final;
			end if;
		end if;
	end process; -- manage_PC

end rtl;