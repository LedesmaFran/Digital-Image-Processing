library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_RX is 
port( CLK: in std_logic;
		RX_LINE: in std_logic;
		DATA: out std_logic_vector(7 downto 0);
		BUSY: out std_logic := '1');

END uart_RX;

architecture atch_RX of uart_RX is

signal DATAFLL: std_logic_vector(9 downto 0);
signal RX_FLG : std_logic:='0';
signal PRSCL: integer range 0 to 63:=0;
signal INDEX: integer range 0 to 9:=0;

begin
	process(CLK)
	begin
		if rising_edge(CLK) then
			if(RX_FLG = '0') then
				if(RX_LINE = '0') then
					INDEX<=0;
					PRSCL<=0;
					RX_FLG<='1';
					BUSY<='1';
				end if;
			end if;
	
			if(RX_FLG='1')then
				DATAFLL(INDEX)<=RX_LINE;
				if(PRSCL<27)then
					PRSCL<=PRSCL+1;
				else
					PRSCL <= 0; 
				end if;
			
		
				if(PRSCL=13)then
					if(INDEX<9)then
						INDEX<=INDEX+1;
					else
						if(DATAFLL(0) = '0' AND DATAFLL(9) = '1')then
							DATA<=DATAFLL(8 downto 1);
						else
--							DATA<=(OTHERS=>'0');
							DATA <= "11100111";
						end if;
						RX_FLG<='0';
						BUSY<='0';
					end if;
				end if;
			end if;
		end if;
	end process;
end architecture;
	