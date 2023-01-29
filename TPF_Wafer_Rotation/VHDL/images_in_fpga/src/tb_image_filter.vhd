LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;	 
use std.textio.all;
use ieee.std_logic_textio.all;

ENTITY tb_image_filter IS
	GENERIC (
	    ADDR_WIDTH     		: integer := 16;        
	    DATA_WIDTH     		: integer := 8;
	    IMAGE_HEIGHT		: integer := 6;
		IMAGE_WIDTH			: integer := 6;
		IMAGE_FILE_NAME 	: string  := "test_img.mif"       
  	);
END tb_image_filter;

ARCHITECTURE behavior OF tb_image_filter IS 
	COMPONENT RAM_block
	GENERIC (
	    ADDR_WIDTH     		: integer := ADDR_WIDTH;        
	    DATA_WIDTH     		: integer := DATA_WIDTH;
	    IMAGE_HEIGHT		: integer := IMAGE_HEIGHT;
		IMAGE_WIDTH			: integer := IMAGE_WIDTH;
		IMAGE_FILE_NAME 	: string  := "test_img.mif"       
  	);	
	PORT (
		clock 		: IN  std_logic;
		data 		: IN  std_logic_vector(DATA_WIDTH-1 downto 0);
		rdaddress 	: IN  std_logic_vector(ADDR_WIDTH-1 downto 0);
		wraddress 	: IN  std_logic_vector(ADDR_WIDTH-1 downto 0);
		we 			: IN  std_logic;
		re 			: IN  std_logic;
		q 			: OUT  std_logic_vector(DATA_WIDTH-1 downto 0)
	);
    END COMPONENT;
	COMPONENT binarization is
	PORT (
		not_enable	: IN STD_LOGIC;
		clock		: IN STD_LOGIC;
		data_in		: IN std_logic_vector ((DATA_WIDTH-1) DOWNTO 0);
		data_out	: OUT std_logic_vector ((DATA_WIDTH-1) DOWNTO 0)
	);
	end COMPONENT;
	COMPONENT image_filter is
	generic(
		IMAGE_WIDTH 	: integer := IMAGE_WIDTH;
		IMAGE_HEIGHT 	: integer := IMAGE_HEIGHT;
		LENGTH_BITS		: integer := 8;
		KERNEL_WIDTH 	: integer := 3;
		DATA_WIDTH		: integer := DATA_WIDTH
		);
	port(
		clock		: IN std_logic;
		not_enable	: IN std_logic;
		pixel_in	: IN std_logic_vector(DATA_WIDTH-1 downto 0);
		filter_sel	: IN std_logic_vector(1 downto 0);
		pixel_out	: OUT std_logic_vector(DATA_WIDTH-1 downto 0);
		counter_out	: OUT std_logic_vector(16 downto 0) := (others => '0');
		out_valid	: OUT std_logic
		);
  	end COMPONENT;
	-- RAM signals
	signal clock 		: std_logic := '1';
	signal data 		: std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
	signal rdaddress 	: std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
	signal wraddress 	: std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
	signal we 			: std_logic := '0';
	signal re 			: std_logic := '0';
	signal q 			: std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');

   	-- Clock period definitions
   	constant clock_period 	: time := 10 ns;
   	
	-- Filter signals
	signal enable			: std_logic := '1';
	signal data_out			: std_logic_vector(DATA_WIDTH-1 downto 0);
	signal filter_sel 		: std_logic_vector(1 downto 0) := "00";
	signal counter_out		: std_logic_vector(16 downto 0);
	signal out_valid		: std_logic;
	
	-- AUX signals
	signal i 				: integer := 0;
	signal q_reg			: std_logic_vector(DATA_WIDTH-1 downto 0);
	
BEGIN
	-- Read image in VHDL
	ram_image: RAM_block GENERIC MAP(
	    ADDR_WIDTH     	=> ADDR_WIDTH,        
	    DATA_WIDTH     	=> DATA_WIDTH,
	    IMAGE_HEIGHT	=> IMAGE_HEIGHT,
		IMAGE_WIDTH		=> IMAGE_WIDTH,
		IMAGE_FILE_NAME => IMAGE_FILE_NAME       
  	)
	PORT MAP (
		clock => clock,
		data => data,
		rdaddress => rdaddress,
		wraddress => wraddress,
		we => we,
		re => re,
		q => q_reg
	);
	
	--bin: binarization PORT MAP (
	--	not_enable => enable,
	--	clock => clock,
	--	data_in => q,
	--	data_out => data_out
	--);
	
	filter : image_filter GENERIC MAP (
		IMAGE_HEIGHT => IMAGE_HEIGHT,
		IMAGE_WIDTH	 => IMAGE_WIDTH,
		LENGTH_BITS	=> 16,
		KERNEL_WIDTH => 3,
		DATA_WIDTH	=> DATA_WIDTH
	)
	PORT MAP (
		filter_sel => filter_sel,
		not_enable => enable,
		clock => clock,
		pixel_in => q,
		pixel_out => data_out,
		counter_out => counter_out,
		out_valid => out_valid
	);

	-- Clock process definitions
	clock_process: 	process
   	begin
		clock <= '1';
	  	wait for clock_period/2;
		clock <= '0';
	  	wait for clock_period/2;
   	end process;
   	
	
	-- Stimulus process
   	stim_proc: process
	file test_vector 	: text open write_mode is "filter_delta_test.txt";
	variable row      	: line;
   	begin
		wait for clock_period;
		re <= '1';
		
		for i in 0 to (IMAGE_HEIGHT*IMAGE_WIDTH)-1 loop
		  	rdaddress <= std_logic_vector(to_unsigned(i, ADDR_WIDTH));	
			wait for clock_period/2;
			q <= q_reg;
			enable <= '0';
			wait for clock_period/2;
			if (out_valid = '1') then
			  	write(row,data_out);
				writeline(test_vector,row);
			else null;
			end if;
		end loop;
		wait;
  	end process;
 
END;