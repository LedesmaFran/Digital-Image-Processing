library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity UART_Test is
port( CLOCK_50	: in STD_LOGIC;
		RST		: in STD_LOGIC;
		SW			: in STD_LOGIC_VECTOR(3 downto 0);
		send		: in STD_LOGIC;
		LED		: out STD_LOGIC_VECTOR(7 downto 0);
		UART_TXD : out STD_LOGIC;
		UART_RXD : in STD_LOGIC);
		
END UART_Test;


architecture MAIN of UART_Test is
signal TX_DATA:  STD_LOGIC_VECTOR(7 downto 0);
signal TX_START: STD_LOGIC:='0';
signal TX_BUSY:  STD_LOGIC;
signal RX_DATA:  STD_logic_vector(7 downto 0);
signal RX_BUSY:  STD_LOGIC;
signal LAST_RX:  STD_LOGIC_VECTOR(7 downto 0);

----------------------------------------------
component TX is
port( CLK :IN STD_LOGIC;
		START:IN STD_LOGIC;
		BUSY:OUT STD_LOGIC;
		DATA: IN STD_LOGIC_VECTOR(7 downto 0);
		TX_LINE:OUT STD_LOGIC);
end component;
----------------------------------------------
component RX is
port( CLK: in STD_LOGIC;
		RX_LINE: in STD_LOGIC;
		DATA: out STD_LOGIC_VECTOR(7 downto 0);
		BUSY: out STD_LOGIC);
end component;
----------------------------------------------

begin
C1: TX PORT MAP(CLOCK_50,TX_START,TX_BUSY,TX_DATA,UART_TXD);
C2: RX PORT MAP(CLOCK_50,UART_RXD,RX_DATA,RX_BUSY);

	process(RX_BUSY, RST)
	begin
		if RST = '0' then
			LAST_RX <= "00000000";
		elsif falling_edge(RX_BUSY) then
			LAST_RX <= RX_DATA;
		end if;
	end process;

	LED <= LAST_RX;
	
	process(CLOCK_50,RST)
	begin
		if RST = '0' then
			TX_DATA <= "00000000";
		elsif rising_edge(CLOCK_50) then
			if(send = '0' and TX_BUSY = '0') then
				TX_DATA<= "0101" & SW(3 downto 0);
				TX_START<='1';
			else
				TX_START<='0';
			end if;
		end if;
	end process;

end architecture;