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

begin


	adder32_PC : entity work.adder_32(rtl)
	port map(
		i_A => r_PC,
		i_B => std_ulogic_vector(to_unsigned(1,r_PC'length)),
		o_result => w_PC_adder_out);


	sign_extend : entity work.sign_extend(rtl)
	port map(
		i_data =>w_curr_instr(15 downto 0),
		o_data => w_sign_extend_out);


	adder32_branch : entity work.adder_32(rtl)
	port map(
		i_A => w_PC_adder_out,
		i_B => w_sign_extend_out,				--word addresable
		--i_B => w_shift_out,
		o_result => w_branch_add_out);

	mux2_32_PC : entity work.mux2(rtl)
	generic map(
		g_width => 32)
	port map(
		i_A =>w_PC_adder_out,
		i_B=>w_branch_add_out,
		i_sel=>w_PC_mux,
		o_out=>w_PC);

	w_j_immediate  <= std_ulogic_vector(resize(unsigned(w_curr_instr(25 downto 0)),32));
	mux2_32_PC_final : entity work.mux2(rtl)
	generic map(
		g_width => 32)
	port map(
		i_A =>w_PC,
		i_B=> w_j_immediate,
		i_sel=>w_jump,
		o_out=>w_PC_final);

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

	control_unit : entity work.control_unit(rtl)
	port map(
		i_opcode =>w_curr_instr(31 downto 26),
		o_alu_op => w_alu_op,
		o_jump => w_jump,
		o_control_bus=> w_control_bus);

	alu_decoder : entity work.alu_decoder(rtl)
	port map(
		i_alu_op => w_alu_op,
		i_func => w_curr_instr(5 downto 0),
		o_alu_control => w_alu_control);

	mux2_5_reg_write_addr : entity work.mux2(rtl)
	generic map(
		g_width => 5)
	port map(
		i_A => w_curr_instr(20 downto 16),
		i_B => w_curr_instr(15 downto 11),
		i_sel => w_reg_dst,
		o_out => w_reg_write_addr);

	reg_file : entity work.reg_file(rtl)
	generic map(
		g_width => 32,
		g_depth => 5)
	port map(
		i_clk =>i_clk,
		i_rst =>i_rst,
		i_we => w_reg_write,
		i_waddr => w_reg_write_addr,
		i_raddr_A => w_curr_instr(25 downto 21), 
		i_raddr_B => w_curr_instr(20 downto 16),
		i_data => w_reg_file_data,
		o_data_A => w_reg_rdataA,
		o_data_B => w_reg_rdataB);	


	mux2_32_alu_inB : entity work.mux2(rtl)
	generic map(
		g_width => 32)
	port map(
		i_A => w_reg_rdataB,
		i_B=> w_sign_extend_out,
		i_sel=>w_alu_src,
		o_out=> w_alu_inB);

	alu : entity work.alu(rtl) 
	generic map(
		g_width => 32)
	port map(
		i_A => w_reg_rdataA,
		i_B => w_alu_inB,
		i_op => w_alu_control,
		o_zero => w_alu_zero,
		o_out => w_alu_out);

	memory_DataMem : entity work.d_memory(rtl)
	generic map(
		g_width =>32,
		g_depth =>12)
	port map(
		i_clk => i_clk,
		i_en => '1',
		i_we => w_mem_write,
		i_addr => w_alu_out,
		i_data => w_reg_rdataB,
		o_data => w_data_mem_out);

	mux2_1_bne : entity work.mux2_bit(rtl)
	generic map(
		g_width => 1)
	port map(
		i_A => w_alu_zero,
		i_B => not w_alu_zero,
		i_sel => w_curr_instr(26),
		o_out => w_mux_bne);

	mux2_32_reg_write_data : entity work.mux2(rtl)
	generic map(
		g_width => 32)
	port map(
		i_A => w_alu_out,
		i_B => w_data_mem_out,
		i_sel => w_mem_to_reg,
		o_out => w_reg_file_data);

	w_PC_mux <= w_branch and w_mux_bne;

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