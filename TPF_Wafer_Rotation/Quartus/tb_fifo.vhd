library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use std.textio.all;

entity tb_fifo is
	generic (
		LENGTH		: integer := 5;
		LENGTH_BITS	: integer := 3;
		DATA_WIDTH	: integer := 8
	);
end tb_fifo;	

architecture behavior of tb_fifo is
	component fifo
	generic(
		LENGTH 		: integer := 5;
		LENGTH_BITS	: integer := 3;
		DATA_WIDTH 	: integer := 8
	);
	port(
		not_enable	: IN std_logic;
		clock		: IN std_logic;
		data_in		: IN std_logic_vector(DATA_WIDTH-1 downto 0);
		data_out	: OUT std_logic_vector(DATA_WIDTH-1 downto 0);
		stack_full	: OUT std_logic;
		counter_out : OUT std_logic_vector (LENGTH_BITS-1 downto 0) := (others => '0')
	);
	end component;
	
	--Signals
	signal clock 		: std_logic := '0';
	signal data_test	: std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
	signal enable		: std_logic := '1';	
	signal data_out		: std_logic_vector(DATA_WIDTH-1 downto 0);
	signal stack_full	: std_logic := '1';
	signal counter_out 	: std_logic_vector (LENGTH_BITS-1 downto 0) := (others => '0');
	
	-- Clock period
	constant clock_period 	: time := 10 ns;
	
	-- Auxiliary signals
	signal i : integer;
	
begin
	uut: fifo generic map (
		LENGTH => LENGTH,
		LENGTH_BITS	=> LENGTH_BITS,
		DATA_WIDTH => DATA_WIDTH
	)
	port map (
		not_enable => enable,
		clock => clock,
		data_in	=> data_test,
		data_out => data_out,
		stack_full => stack_full,
		counter_out => counter_out
	);
	-- Clock process definitions
	clock_process: process
   	begin
		clock <= '0';
	  	wait for clock_period/2;
	  	clock <= '1';
	  	wait for clock_period/2;
   	end process;
	   
	-- Stimulation process
	stim_proc: process
	begin
	data_test <= data_test + 1;
	wait for 10 ns;
	enable <= '0';
	wait for 10 ns;
	for i in 0 to 10 loop
		data_test <= data_test + 1;
		wait for 10 ns;
	end loop;
	wait;	
	end process;
end;

		
	