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
		
		UART_RX_FIFO_FULL : out std_logic := '0';
		UART_RX_RECIEVED_ALL : out std_logic := '1';
		UART_RX_RECIEVED_NONE : out std_logic := '0'
		
);

END uart_RX;

architecture atch_RX of uart_RX is

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



signal DATAFLL			: std_logic_vector(9 downto 0);
signal RX_FLG 			: std_logic:='0';
signal PRSCL			: integer range 0 to 900:=0;
signal INDEX			: integer range 0 to 9:=0;
signal INT_UART_CLK	: std_logic := '1';

-- fifo signals
signal data_valid 	: std_logic := '0';
signal fifo_ready		: std_logic := '1';


type state_type is (IDLE, SAMPLE, COLLECT, CHECK, STORE, SEND);
signal current_state : state_type := IDLE;


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

	

process (CLK)
--variable COUNT : integer range 0 to 7:=0;
begin
  if rising_edge(CLK) then
  
    --current_state <= next_state;
	 
    case current_state is
	 
      when IDLE =>
		
        if RX_LINE = '0' then
		     --COUNT := COUNT+1;
			  --if (COUNT = 1) then
				-- UART_RX_RECIEVED_NONE <= '1';
			  --else
				-- UART_RX_RECIEVED_NONE <= '0';
			  --end if;
			  
          current_state <= SAMPLE;
        end if;
		  
		  
      when SAMPLE =>
        PRSCL <= 434;
        INDEX <= 0;
        INT_UART_CLK <= '1';
        current_state <= COLLECT;
		  
		  
      when COLLECT =>
        if PRSCL < 868 then
          PRSCL <= PRSCL + 1;
        else
			 PRSCL <= 0;
          DATAFLL(INDEX) <= RX_LINE;
          INT_UART_CLK <= not INT_UART_CLK;
          UART_CLK <= INT_UART_CLK;
          if INDEX < 9 then
            INDEX <= INDEX + 1;
          else
            current_state <= CHECK;
          end if;
        end if;
		  
		  
      when CHECK =>
        if DATAFLL(0) = '0' and DATAFLL(9) = '1' then
		    --UART_RX_RECIEVED_ALL <= '1';
          current_state <= STORE;
        else
		    UART_RX_RECIEVED_ALL <= '0';
			 data_valid <= '0';
          current_state <= IDLE;
        end if;
		  
		  
      when STORE =>
        data_valid <= '1';
        current_state <= SEND;
		  
		  
      when SEND =>
        if data_valid = '1' AND fifo_ready = '1' then
          data_valid <= '0';
          current_state <= IDLE;
        end if;
    end case;
	 
  end if;
end process;
end architecture;
	