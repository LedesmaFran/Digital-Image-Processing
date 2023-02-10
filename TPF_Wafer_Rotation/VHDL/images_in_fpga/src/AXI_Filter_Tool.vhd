library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


ENTITY AXI_Filter_Tool IS
	GENERIC (
	   	ADDR_WIDTH     	: integer := 16;        
	   	DATA_WIDTH     	: integer := 8;
	   	IMAGE_HEIGHT	: integer := 256+4;
		IMAGE_WIDTH		: integer := 256+4;
		IMAGE_FILE_NAME : string  := "wafer_gray.mif"       
  	);	
	PORT( 
		clock		: IN std_logic;
		
		valid_in 	: IN std_logic;
		ready_out	: OUT std_logic := '1';
		
		pixel_in	: IN std_logic_vector(DATA_WIDTH-1 downto 0);
		pixel_out	: OUT std_logic_vector(DATA_WIDTH-1 downto 0);
		
		--counter_out	: OUT std_logic_vector(17 downto 0) := (others => '0');
		--out_valid	: OUT std_logic
		
		ready_in	: IN std_logic := '0';
		valid_out	: OUT std_logic := '0'		
	);
END AXI_Filter_Tool;

architecture behavioral of AXI_Filter_Tool is

	-- Filter Tool component
	COMPONENT Image_Filter_Tool IS
	GENERIC (
	   	ADDR_WIDTH     	: integer := ADDR_WIDTH;        
	   	DATA_WIDTH     	: integer := DATA_WIDTH;
	   	IMAGE_HEIGHT	: integer := IMAGE_HEIGHT;
		IMAGE_WIDTH		: integer := IMAGE_WIDTH;
		IMAGE_FILE_NAME : string  := IMAGE_FILE_NAME       
  	);
	PORT(
		clock		: IN std_logic;
		
		enable		: IN std_logic := '1';
		
		pixel_in	: IN std_logic_vector(DATA_WIDTH-1 downto 0);
		pixel_out	: OUT std_logic_vector(DATA_WIDTH-1 downto 0);
		
		--counter_out	: OUT std_logic_vector(17 downto 0) := (others => '0');
		out_valid	: OUT std_logic
	);	
	END COMPONENT;

	--Prescale clock signals
	signal prscl_clock : std_logic := '0';
	
	-- Filter Tool signals
	signal enable 			: std_logic := '1';
	signal filter_out_valid	: std_logic := '0';
	
	signal pixel_in_reg		: std_logic_vector(DATA_WIDTH-1 downto 0);
	signal pixel_out_reg	: std_logic_vector(DATA_WIDTH-1 downto 0);
	
	-- AUX signals
	signal valid_out_flag : std_logic := '0';
	
begin
	
	filter_tool: Image_Filter_Tool 
	generic map (
	   	ADDR_WIDTH		=> ADDR_WIDTH,        
	   	DATA_WIDTH		=> DATA_WIDTH,
	   	IMAGE_HEIGHT	=> IMAGE_HEIGHT,
		IMAGE_WIDTH		=> IMAGE_WIDTH,
		IMAGE_FILE_NAME => IMAGE_FILE_NAME       
  	)
	port map(
		clock		=> clock,
		
		enable		=> enable,
		
		pixel_in	=> pixel_in,
		pixel_out	=> pixel_out_reg,
		
		--counter_out	: OUT std_logic_vector(17 downto 0) := (others => '0');
		out_valid	=> filter_out_valid
	);
	
	-- Prescale	clock process
--		prescaler_process: process (clock)
--		variable PRSCL : integer := 108;
--		begin
--			if rising_edge(clock) then
--				if(PRSCL<216)then
--					PRSCL:=PRSCL+1;
--					if (PRSCL = 108) then
--						prscl_clock <= not prscl_clock;
--					end if;
--				else
--					PRSCL := 0; 
--				end if;
--			end if;	
--		end process;
	
	exec_process: process (clock)
	
	begin
		if (rising_edge(clock)) then
		
			if (valid_in = '1') then
				enable <= '0';
			else
				enable <= '1';
			end if;
			if (filter_out_valid = '1') then
				valid_out_flag <= '1';
				valid_out <= '1';
			end if;
			if (valid_out_flag = '1' and ready_in = '1') then
				pixel_out <= pixel_out_reg;
				valid_out_flag <= '0';
				valid_out <= '0';
			end if;
		end if;
	end process;
	
	
end architecture;
