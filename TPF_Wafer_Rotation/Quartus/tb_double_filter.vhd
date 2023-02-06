LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;	 
use std.textio.all;
use ieee.std_logic_textio.all;

ENTITY tb_image_double_filter IS
	GENERIC (
	    ADDR_WIDTH     		: integer := 16;        
	    DATA_WIDTH     		: integer := 8;
	    IMAGE_HEIGHT		: integer := 256+4;
		IMAGE_WIDTH			: integer := 256+4;
		IMAGE_FILE_NAME 	: string  := "wafer_gray.mif"       
  	);
END tb_image_double_filter;

ARCHITECTURE behavior OF tb_image_double_filter IS 
	COMPONENT RAM_block
	GENERIC (
	    ADDR_WIDTH     		: integer := ADDR_WIDTH;        
	    DATA_WIDTH     		: integer := DATA_WIDTH;
	    IMAGE_HEIGHT		: integer := IMAGE_HEIGHT;
		IMAGE_WIDTH			: integer := IMAGE_WIDTH;
		IMAGE_FILE_NAME 	: string  := "wafer_gray.mif"       
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
		type_sel	: IN std_logic_vector(1 downto 0);
		pixel_out	: OUT std_logic_vector(DATA_WIDTH-1 downto 0);
		counter_out	: OUT std_logic_vector(17 downto 0) := (others => '0');
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
	
	-- RAM2 signals
	signal data2 		: std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
	signal rdaddress2 	: std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
	signal wraddress2 	: std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
	signal we2 			: std_logic := '0';
	signal re2			: std_logic := '0';
	signal q2 			: std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');

   	-- Clock period definitions
   	constant clock_period 	: time := 10 ns;
   	
	-- Filter1 signals
	signal enable			: std_logic := '1';
	signal data_out			: std_logic_vector(DATA_WIDTH-1 downto 0);
	signal filter_sel 		: std_logic_vector(1 downto 0) := "00";
	signal type_sel 		: std_logic_vector(1 downto 0) := "10";	 -- 00 => kernel / 01 => erosion / 10 => dilation 
	signal counter_out		: std_logic_vector(17 downto 0);
	signal out_valid		: std_logic;
	
	-- Filter2 signals
	signal enable2			: std_logic := '1';
	signal data_out2		: std_logic_vector(DATA_WIDTH-1 downto 0);
	signal filter_sel2 		: std_logic_vector(1 downto 0) := "00";
	signal type_sel2 		: std_logic_vector(1 downto 0) := "01";	 -- 00 => kernel / 01 => erosion / 10 => dilation 
	signal counter_out2		: std_logic_vector(17 downto 0);
	signal out_valid2		: std_logic;
	
	-- Binarization signals
	signal bin_out			: std_logic_vector(DATA_WIDTH-1 downto 0);
	signal bin_enable_test 	: std_logic := '0';
	
	-- AUX signals
	signal i 				: integer := 0;
	signal j 				: integer := 0;	
	signal k 				: integer := 0;
	signal q_reg			: std_logic_vector(DATA_WIDTH-1 downto 0); 
	signal q_reg2			: std_logic_vector(DATA_WIDTH-1 downto 0);
	
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
	
	ram2: RAM_block GENERIC MAP(
	    ADDR_WIDTH     	=> ADDR_WIDTH,        
	    DATA_WIDTH     	=> DATA_WIDTH,
	    IMAGE_HEIGHT	=> IMAGE_HEIGHT,
		IMAGE_WIDTH		=> IMAGE_WIDTH,
		IMAGE_FILE_NAME => IMAGE_FILE_NAME       
  	)
	PORT MAP (
		clock => clock,
		data => data2,
		rdaddress => rdaddress2,
		wraddress => wraddress2,
		we => we2,
		re => re2,
		q => q_reg2
	);
	
	bin: binarization PORT MAP (
		not_enable => enable,
		data_in => q,
		data_out => bin_out
	);
	
	filter : image_filter GENERIC MAP (
		IMAGE_HEIGHT => IMAGE_HEIGHT,
		IMAGE_WIDTH	 => IMAGE_WIDTH,
		LENGTH_BITS	=> 16,
		KERNEL_WIDTH => 3,
		DATA_WIDTH	=> DATA_WIDTH
	)
	PORT MAP (
		filter_sel => filter_sel,
		type_sel => type_sel,
		not_enable => enable,
		clock => clock,
		pixel_in => bin_out,
		pixel_out => data_out,
		counter_out => counter_out,
		out_valid => out_valid
	);
	
	filter2 : image_filter GENERIC MAP (
		IMAGE_HEIGHT => IMAGE_HEIGHT-2,
		IMAGE_WIDTH	 => IMAGE_WIDTH-2,
		LENGTH_BITS	=> 16,
		KERNEL_WIDTH => 3,
		DATA_WIDTH	=> DATA_WIDTH
	)
	PORT MAP (
		filter_sel => filter_sel2,
		type_sel => type_sel2,
		not_enable => enable2,
		clock => clock,
		pixel_in => q2,
		pixel_out => data_out2,
		counter_out => counter_out2,
		out_valid => out_valid2
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
   	begin
		wait for clock_period;
			re <= '1';
		for i in 0 to (IMAGE_HEIGHT*IMAGE_WIDTH)-1 loop
			rdaddress <= std_logic_vector(to_unsigned(i, ADDR_WIDTH));	
			wait for clock_period/2;
			q <= q_reg;
			if ((out_valid = '0') and (to_integer(unsigned(counter_out)) > (IMAGE_HEIGHT*IMAGE_WIDTH-2*IMAGE_HEIGHT-1))) then
				enable <= '1';
			else
				enable <= '0';
			end if;
			wait for clock_period/2;
		end loop;
		
  	end process;
	
	-- Middleman process
	middle_proc: process (clock, out_valid, data_out)
	begin
		if (rising_edge(clock)) then
			we2 <= out_valid;
			if (out_valid = '1') then
				j <= j + 1;
				data2 <= data_out;
				wraddress2 <= std_logic_vector(to_unsigned(j, ADDR_WIDTH));
			else null;	
			end if;
		else null;
		end if;
	end process;
	
	-- Stimulus process 2
   	stim_proc2: process (clock, counter_out, out_valid)
	begin
		if (rising_edge(clock)) then				
			if (to_integer(unsigned(counter_out)) > (IMAGE_HEIGHT*IMAGE_WIDTH-2*IMAGE_HEIGHT-3) and (to_integer(unsigned(counter_out2)) <= ((IMAGE_HEIGHT-2)*(IMAGE_WIDTH-2)-2*(IMAGE_HEIGHT-2)))) then
				re2 <= '1';
				rdaddress2 <= std_logic_vector(to_unsigned(k, ADDR_WIDTH));	
				q2 <= q_reg2;
				k <= k + 1;
			else 
				enable2 <= '1';
			end if;
			if ((out_valid = '0') and (to_integer(unsigned(counter_out)) > (IMAGE_HEIGHT*IMAGE_WIDTH-2*IMAGE_HEIGHT-1)) and (to_integer(unsigned(counter_out2)) <= ((IMAGE_HEIGHT-2)*(IMAGE_WIDTH-2)-2*(IMAGE_HEIGHT-2)))) then
				enable2 <= '0';
			else 
				enable2 <= '1';
			end if;
		else null;
		end if;
  	end process;
	
	-- Output process
	out_proc: process (clock)
	file test_vector 	: text open write_mode is "fpga_output.txt";
	variable row      	: line;
   	begin
		if (rising_edge(clock)) then
			if (out_valid2 = '1') then
				write(row,data_out2);
				writeline(test_vector,row);
			else null;
			end if;
		else null;
		end if;	
	end process;
END;