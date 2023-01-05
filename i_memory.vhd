--Single port RAM with asynchronous read (Distributed RAM)
--The following is a low latency design(1 clock cycle). To increase
--performance, the latency can be increased by 1 clock cycle by using an 
--output register, to improve clock-to-out timing.


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity i_memory is
	generic(
		g_width : natural :=8;
		g_depth : natural :=10);
	port(
		i_clk : in std_ulogic;
		i_en : in std_ulogic;
		i_we : in std_ulogic;
		i_addr : in std_ulogic_vector(31 downto 0);
		i_data : in std_ulogic_vector(g_width -1 downto 0);
		o_data : out std_ulogic_vector(g_width -1 downto 0));
end i_memory;

architecture rtl of i_memory is
	type ram_type is array(2**g_depth -1 downto 0) of std_ulogic_vector(g_width -1 downto 0);
	--signal memory : std_ulogic_vector(4*1024 downto 0);
	--signal mem : ram_type:=(0=> x"01285020",1=>x"01484020",2=>x"01404820",3=>x"01285020",others => (others => '0'));
	
	--signal mem : ram_type:=(0=>x"11200190", 1=>x"08000006" ,2=>x"8d490190",3=>x"11200190" ,4=> x"01285020",5=>x"ad2a0064",6=> x"ad490064" ,7 =>x"08000002",8=>x"01285020",others => (others => '0'));
	---------signal mem : ram_type:=(0=>x"11290005",1=>x"8d490190",2=>x"11200190" ,3=> x"01285020",4=>x"ad2a0064",5=> x"ad490064",others => (others => '0'));
	
	signal mem : ram_type:=(0=>x"11290003",1=>x"01285020",2=>x"01404820",3=>x"01285020",4=>x"8d490190",5=>x"11200190",6=>x"01285020",406 => x"08000000",others => (others => '0'));
begin

	o_data <= mem(to_integer(unsigned(i_addr(11 downto 0))));

	write_2_mem : process(i_clk)
	begin
		if(rising_edge(i_clk)) then
			if(i_en = '1') then
				if(i_we = '1') then
					mem(to_integer(unsigned(i_addr(11 downto 0)))) <= i_data;
					--o_data <= i_data;
				--else
					--o_data <= mem(to_integer(unsigned(i_addr(11 downto 0))));
				end if;
			end if;
		end if;
	end process; -- write_2_mem
end rtl;


--beq $t1 $t1 3  (opcode/func : 4 hex)
-- 0001 0001 0010 1001 0000   0000 0000 0011
--  1    1    2    9     0     0    0    3

--beq $t1 $0 400  (opcode/func : 4 hex)
-- 0001 0001 0010 0000 0000   0001 1001 0000
--  1    1    2    0     0     1    9    0

-- j 6
--0000 1000 0000 0000 0000 0000 0000  0110
-- 0    8    0    0    0     0   0     6

--lw $t1,400($t2) (opcode/func : 23 hex)
--1000 1101 0100 1001  0000   0001 1001 0000
-- 8    d    4    9      0     1    9    0

--beq $t1 $0 400  (opcode/func : 4 hex)
-- 0001 0001 0010 0000 0000   0001 1001 0000
--  1    1    2    0     0     1    9    0

--add $t2,$t1,$t0  (opcode/func : 0/20 hex)				
--op		t1(rs)  t0(rt)  t2(rd) shamt     func
--000000       01001  01000   01010   00000     100000
--0000 0001 0010 1000 0101 0000 0010 0000
--0      1   2     8     5  0     2 0

--sw $t1,100($t2)  (opcode/func : 2b hex)
-- 1010 1101  0010  1010   0000 0000 0110 0100
--	a	d	    2	 a      0	0	  6  4

--sw $t2,100($t1)  (opcode/func : 2b hex)
-- 1010 1101 0100 1001    0000 0000 0110 0100
--	a	  d    4   9      0	     0	  6  4

-- j 2
--0000 1000 0000 0000 0000 0000 0000  0010
-- 0    8    0    0    0     0   0     2





--Test forward
--add $t1,$t2,$0  (opcode/func : 0/20 hex)				
--op		t2(rs)  0(rt)  t1(rd) shamt     func
--000000       01010  00000   01001   00000     100000
--0000  0001 0100 0000   0100 1000 0010 0000
--0      1    4     0     4     8        2        0

--add $t2,$t1,$t0  (opcode/func : 0/20 hex)				
--op		t1(rs)  t0(rt)  t2(rd) shamt     func
--000000       01001  01000   01010   00000     100000
--0000   0001 0010 1000   0101 0000 0010 0000
-- 0       1     2  8       5   0      2   0

--add $t0,$t2,$t0  (opcode/func : 0/20 hex)				
--op		t2(rs)  t0(rt)  t0(rd) shamt     func
--000000       01010  01000   01000   00000     100000
--0000 0001 0100 1000   0100 0000 0010 0000
-- 0    1    4    8       4    0   2     0


