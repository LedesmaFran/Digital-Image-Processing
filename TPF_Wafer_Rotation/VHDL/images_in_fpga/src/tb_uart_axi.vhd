LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;	 
use std.textio.all;
use ieee.std_logic_textio.all;

ENTITY tb_uart_axi IS

END tb_uart_axi;

ARCHITECTURE behavior OF tb_uart_axi IS 

	-- uart_rx component
	COMPONENT uart_RX is 
	port( 
			CLK			: in std_logic;
			
			UART_CLK	: out std_logic;
			
			VALID_IN 	: in std_logic := '1';
			READY_OUT	: out std_logic := '1';
			
			RX_LINE		: in std_logic; -- data in
			
			DATA_OUT	: out std_logic_vector(7 downto 0);
			
			READY_IN	: in std_logic := '0';
			VALID_OUT	: out std_logic := '0';
			
			UART_RX_FIFO_FULL : out std_logic := '0'
	);
	END COMPONENT;
	
	-- uart_tx component
	COMPONENT uart_TX IS
	PORT( 
			CLK			: in std_logic;
			
			VALID_IN 	: in std_logic := '0';
			READY_OUT	: out std_logic := '0';
			
			DATA_IN		: in std_logic_vector(7 downto 0);
			
			TX_LINE		: out std_logic; -- data out
			
			READY_IN	: in std_logic := '1';
			VALID_OUT	: out std_logic := '1';
			
			UART_TX_FIFO_FULL : out std_logic := '0'		
	);
	END COMPONENT;
	
	-- RAM block to emulate input
	COMPONENT RAM_block
	GENERIC (
	    ADDR_WIDTH     		: integer := 8;        
	    DATA_WIDTH     		: integer := 8;
	    IMAGE_HEIGHT		: integer := 4;
		IMAGE_WIDTH			: integer := 4;
		IMAGE_FILE_NAME 	: string  := "desired_output.mif"       
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
	
   	-- Clock period definitions
   	constant clock_period 	: time := 20 ns;
	signal clock 			: std_logic := '1';
	
	
	-- RX Signals
	signal UART_CLK				: std_logic;
	
	signal RX_VALID_IN 			: std_logic := '1';
	signal RX_READY_OUT			: std_logic := '1';
	
	signal RX_LINE				: std_logic; -- data in
	
	signal UART_RX_FIFO_FULL : std_logic := '0';
	
	-- AXI signals
	signal data		: std_logic_vector(7 downto 0);
	signal valid	: std_logic := '0';
	signal ready	: std_logic := '0';
	
	-- TX Signals	
	signal TX_LINE				: std_logic; -- data out
	  
	signal TX_READY_IN			: std_logic := '1';
	signal TX_VALID_OUT			: std_logic := '1';
	
	signal UART_TX_FIFO_FULL 	: std_logic := '0';
	   
	-- AUX signals
	signal test_msg : std_logic_vector(9 downto 0) := (0 => '0', 9 => '1', 
														 1 => '1', 2 => '0', 3 => '1', 4 => '0', 
														 5 => '1', 6 => '0', 7 => '1', 8 => '0');
	signal prscl_clock : std_logic := '1';													 
														 
BEGIN
	
	uart_in : uart_RX
	port map( 
			CLK			=> clock,
			
			UART_CLK	=> UART_CLK,
			
			VALID_IN 	=> RX_VALID_IN,
			READY_OUT	=> RX_READY_OUT,
			
			RX_LINE		=> RX_LINE,
			
			DATA_OUT	=> data,
			
			READY_IN	=> ready,
			VALID_OUT	=> valid,
			
			UART_RX_FIFO_FULL => UART_RX_FIFO_FULL
	);
	
	uart_out : uart_TX
	port map( 
			CLK			=> clock,
			
			READY_OUT	=> ready,
			VALID_IN	=> valid,
			
			DATA_IN	=> data,
			
			TX_LINE		=> TX_LINE,
			
			VALID_OUT 	=> TX_VALID_OUT,
			READY_IN	=> TX_READY_IN,
			
			UART_TX_FIFO_FULL => UART_TX_FIFO_FULL
	);
	
	-- Clock process definitions
	clock_process: 	process
   	begin
		clock <= '1';
	  	wait for clock_period/2;
		clock <= '0';
	  	wait for clock_period/2;
   	end process;
	
	prescaler_process: process (clock)
	variable PRSCL : integer := 108;
	begin
		if rising_edge(clock) then
			if(PRSCL<216)then
				PRSCL:=PRSCL+1;
				if (PRSCL = 108) then
					prscl_clock <= not prscl_clock;
				end if;
				
			else
				PRSCL := 0; 
			end if;
		end if;	
	end process;
	   
	stim_proc:	process	(prscl_clock)
	variable index : integer := 0;
	begin
		if (rising_edge(prscl_clock)) then
			RX_LINE <= test_msg(index);
			index := index + 1;
			if index > 9 then
				index := 0;
				test_msg <= std_logic_vector(to_unsigned(to_integer(unsigned(test_msg)) + 2, 10));
			end if;
		end if;
	end process;   
END;