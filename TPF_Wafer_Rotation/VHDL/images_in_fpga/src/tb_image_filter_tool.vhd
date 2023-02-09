LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;	 
use std.textio.all;
use ieee.std_logic_textio.all;

ENTITY tb_Image_Filter_Tool IS
	GENERIC (
	    ADDR_WIDTH     		: integer := 16;        
	    DATA_WIDTH     		: integer := 8;
	    IMAGE_HEIGHT		: integer := 256+4;
		IMAGE_WIDTH			: integer := 256+4;
		IMAGE_FILE_NAME 	: string  := "wafer_gray.mif"       
  	);
END tb_Image_Filter_Tool;

ARCHITECTURE behavior OF tb_Image_Filter_Tool IS 
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
	COMPONENT Image_Filter_Tool
	GENERIC (
	   	ADDR_WIDTH     	: integer := 16;        
	   	DATA_WIDTH     	: integer := 8;
		IMAGE_HEIGHT	: integer := 256+4;
		IMAGE_WIDTH		: integer := 256+4;
		IMAGE_FILE_NAME : string  := "wafer_gray.mif"       
  	);
	PORT(
		clock		: IN std_logic;
		enable		: IN std_logic;
		pixel_in	: IN std_logic_vector(DATA_WIDTH-1 downto 0);
		pixel_out	: OUT std_logic_vector(DATA_WIDTH-1 downto 0);
		counter_out	: OUT std_logic_vector(17 downto 0) := (others => '0');
		out_valid	: OUT std_logic
		);
	END COMPONENT;
	
	-- clock
	signal clock 		: std_logic := '1';
	
	-- RAM signals
	signal data 		: std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
	signal rdaddress 	: std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
	signal wraddress 	: std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
	signal we 			: std_logic := '0';
	signal re 			: std_logic := '0';
	signal q_reg 		: std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0'); 

   	-- Clock period definitions
   	constant clock_period 	: time := 10 ns;

	-- Image Filter Tool signals
	signal enable		: std_logic := '1';
	signal pixel_in	: std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
	signal pixel_out	: std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
	signal counter_out	: std_logic_vector(17 downto 0) := (others => '0');
	signal out_valid	: std_logic := '0';	 
	
	-- AUX signals
	signal k 	: integer := 0;
	
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
	
	filter_tool: Image_Filter_Tool GENERIC MAP(
		ADDR_WIDTH     	=> ADDR_WIDTH,        
	    DATA_WIDTH     	=> DATA_WIDTH,
	    IMAGE_HEIGHT	=> IMAGE_HEIGHT,
		IMAGE_WIDTH		=> IMAGE_WIDTH,
		IMAGE_FILE_NAME => IMAGE_FILE_NAME  
	)
	PORT MAP (
		clock		=> clock,
		enable		=> enable,
		pixel_in	=> pixel_in,
		pixel_out	=> pixel_out,
		counter_out	=> counter_out,
		out_valid	=> out_valid
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
   	stim_proc: process (clock, counter_out)
   	begin	
		 if (rising_edge(clock)) then				
			if (to_integer(unsigned(counter_out)) < 1) then
				enable <= '0';
				re <= '1';
				rdaddress <= std_logic_vector(to_unsigned(k, ADDR_WIDTH));	
				pixel_in <= q_reg;
				k <= k + 1;	  
			else 
				enable <= '1';
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
			if (out_valid = '1') then
				write(row,pixel_out);
				writeline(test_vector,row);
			else null;
			end if;
		else null;
		end if;	
	end process;
	
END;