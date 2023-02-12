library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


ENTITY uart_TX IS
PORT( 
		CLK		: in std_logic;
		
		VALID_IN : in std_logic := '0';
		READY_OUT: out std_logic := '0';
		
		DATA_IN	: in std_logic_vector(7 downto 0);
		
		TX_LINE	: out std_logic := '1'; -- data out
		
		READY_IN	: in std_logic := '1';
		VALID_OUT: out std_logic := '1';
		
		UART_TX_FIFO_FULL : out std_logic := '0'
		
);
END uart_TX;

architecture arch_TX of uart_TX is


component AXI_FIFO is
generic
(
	DATA_WIDTH	: integer := 8;
	STACK_SIZE	: integer := 900
);
port
(
	clock		: in std_logic;
	
	valid_in : in std_logic := '0';
	ready_out: out std_logic := '1';
	
	data_in	: in std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
	data_out	: out std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');

	ready_in	: in std_logic := '0';
	valid_out: out std_logic := '0';
	
	full		: out std_logic := '0'
);
end component;


signal PRSCL: integer range 0 to 900:=0;
signal INDEX: integer range 0 to 9:=0;
signal DATAFLL: STD_LOGIC_VECTOR(9 downto 0);


-- fifo signals
signal fifo_valid 	: std_logic := '0';
signal tx_ready		: std_logic := '1';
signal fifo_data		: std_logic_vector(7 downto 0);

begin

	fifo : AXI_FIFO
	port map(
		clock => CLK,
		
		valid_in => VALID_IN,
		ready_out => READY_OUT,
		
		data_in 	=> DATA_IN,
		data_out	=> fifo_data,
		
		ready_in => tx_ready,
		valid_out => fifo_valid,
		
		full => UART_TX_FIFO_FULL		
	);
	
	process(CLK)
		begin
		
			if rising_edge(CLK) then
				if (tx_ready = '1' and fifo_valid = '1') then
					tx_ready <= '0';
					DATAFLL(0)<='0';
					DATAFLL(9)<='1';
					DATAFLL(8 downto 1) <= fifo_data;
				else null;
				end if;
			
				if(tx_ready = '0')then
					if(PRSCL<868)then	
						PRSCL <= PRSCL+1;
					else
						PRSCL <= 0;
					end if;
			
					if(PRSCL = 434)then
						TX_LINE<=DATAFLL(INDEX);
						if(INDEX<9)then
							INDEX<=INDEX+1;
						else
							INDEX <= 0;
							tx_ready <= '1';
						end if;
					end if;	
				end if;
			end if;
	end process;
end architecture;
