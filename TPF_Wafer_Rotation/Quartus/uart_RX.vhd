library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_RX is 

port( 

		CLK		: in std_logic;
		
		UART_CLK	: out std_logic := '0';
		
		VALID_IN : in std_logic := '1';
		READY_OUT: out std_logic := '1';
		
		RX_LINE	: in std_logic; -- data in
		
		DATA_OUT	: out std_logic_vector(7 downto 0);
		
		READY_IN	: in std_logic := '0';
		VALID_OUT: out std_logic := '0';
		
		UART_RX_FIFO_FULL : out std_logic := '0'
		
);

END uart_RX;

architecture atch_RX of uart_RX is

component AXI_FIFO is
generic
(
	DATA_WIDTH	: integer := 8;
	STACK_SIZE	: integer := 32
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



signal DATAFLL			: std_logic_vector(9 downto 0);
signal RX_FLG 			: std_logic:='0';
signal PRSCL			: integer range 0 to 450:=0;
signal INDEX			: integer range 0 to 9:=0;
signal INT_UART_CLK	: std_logic := '0';

-- fifo signals
signal data_valid 	: std_logic := '0';
signal fifo_ready		: std_logic := '1';

begin

	fifo : AXI_FIFO
	port map(
		clock => CLK,
		
		valid_in => data_valid,
		ready_out => fifo_ready,
		
		data_in 	=> DATAFLL(8 downto 1),
		data_out	=> DATA_OUT,
		
		ready_in => READY_IN,
		valid_out => VALID_OUT,
		
		full => UART_RX_FIFO_FULL		
	);

	process(CLK)
	begin
		if rising_edge(CLK) then
			if(RX_FLG = '0') then
				if(RX_LINE = '0') then
					INDEX<=0;
					PRSCL<=0;
					RX_FLG<='1';
					--BUSY<='1';
				end if;
			end if;
	
			if(RX_FLG='1')then
				DATAFLL(INDEX)<=RX_LINE;
				if(PRSCL<432)then
					PRSCL<=PRSCL+1;
				else
					PRSCL <= 0; 
				end if;
			
		
				if(PRSCL=216)then
					INT_UART_CLK <= not INT_UART_CLK;
					UART_CLK <= INT_UART_CLK;
					if(INDEX<9)then
						INDEX<=INDEX+1;
					else
						if(DATAFLL(0) = '0' AND DATAFLL(9) = '1')then
							data_valid <= '1';
							--DATA_OUT<=DATA_OUTFLL(8 downto 1);
						else
							data_valid <= '0';
--							DATA_OUT<=(OTHERS=>'0');
							--DATA_OUT <= "11100111";
						end if;
						RX_FLG<='0';
						--BUSY<='0';
					end if;
				end if;
			end if;
			if (data_valid = '1' and fifo_ready = '1') then
				data_valid <= '0';
			end if;
		end if;
	end process;
end architecture;
	