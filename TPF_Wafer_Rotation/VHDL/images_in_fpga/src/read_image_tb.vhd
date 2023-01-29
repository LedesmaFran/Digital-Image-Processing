LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;	 
use std.textio.all;
use ieee.std_logic_textio.all;

ENTITY tb_read_image_vhdl IS
	GENERIC (
	    ADDR_WIDTH     		: integer := 16;        
	    DATA_WIDTH     		: integer := 8;
	    IMAGE_HEIGHT		: integer := 4;
		IMAGE_WIDTH			: integer := 4;
		IMAGE_FILE_NAME 	: string  :="test_img.mif"       
  	);
END tb_read_image_vhdl;

ARCHITECTURE behavior OF tb_read_image_vhdl IS 
	COMPONENT read_image_VHDL
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
  
	--Inputs
	signal clock 		: std_logic := '0';
	signal data 		: std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
	signal rdaddress 	: std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
	signal wraddress 	: std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
	signal we 			: std_logic := '0';
	signal re 			: std_logic := '0';
	
  	--Outputs
	signal q 			: std_logic_vector(DATA_WIDTH-1 downto 0);

   	-- Clock period definitions
   	constant clock_period 	: time := 10 ns;
   	
	--Auxiliary signals
	signal i				: integer;
	signal enable			: std_logic := '0';
	signal data_out			: std_logic_vector(DATA_WIDTH-1 downto 0); 
	   
BEGIN
	-- Read image in VHDL
	uut: read_image_VHDL PORT MAP (
		clock => clock,
		data => data,
		rdaddress => rdaddress,
		wraddress => wraddress,
		we => we,
		re => re,
		q => q
	);
	
	bin: binarization PORT MAP (
		not_enable => enable,
		clock => clock,
		data_in => q,
		data_out => data_out
	);

	-- Clock process definitions
	clock_process: 	process
   	begin
		clock <= '0';
	  	wait for clock_period/2;
	  	clock <= '1';
	  	wait for clock_period/2;
   	end process;
   
	-- Stimulus process
   	stim_proc: process
	file test_vector      : text open write_mode is "binarization_test.txt";
	variable row          : line;
   	begin  
		data <= x"00";
	  	rdaddress <= x"0000";
	  	wraddress <= x"0000";
	  	we <= '0';
	  	re <= '0';
	  	wait for 100 ns;
	  	re <= '1';
	  	for i in 0 to (IMAGE_HEIGHT*IMAGE_WIDTH)-1 loop
		  	rdaddress <= std_logic_vector(to_unsigned(i, ADDR_WIDTH));
  			wait for 20 ns;
			write(row,data_out);
			writeline(test_vector,row);
		end loop;
		wait;
  	end process;
 
END;