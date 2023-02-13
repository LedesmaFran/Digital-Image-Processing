library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity AXI_FIFO is
generic
(
	DATA_WIDTH	: integer := 8;
	STACK_SIZE	: integer := 110
);
port
(
	clock		: in std_logic;
	valid_in : in std_logic := '0';
	data_in	: in std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
	ready_in	: in std_logic := '0';
	data_out	: out std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
	valid_out: out std_logic := '0';
	ready_out: out std_logic := '1';
	full		: out std_logic := '0'
);
end AXI_FIFO;

architecture behavioral of AXI_FIFO is

type stack_t is array(0 to STACK_SIZE-1) of std_logic_vector(DATA_WIDTH-1 downto 0);

signal stack 			: stack_t := (others => (others => '0'));
signal valid_out_flag: std_logic := '0';
signal stack_pointer 	: integer := STACK_SIZE-1; 	   

begin

	process (clock, data_in, valid_in, ready_in)
	variable counter		: integer := 0;
	begin
		if (rising_edge(clock)) then
				-- stack update and data input
				if (valid_in = '1') then
					stack(stack_pointer) <= data_in;
					stack_pointer <= stack_pointer - 1;
					if (stack_pointer = 1) then
						full <= '1';
						ready_out <= '0';
					else 
						ready_out <= '1';
					end if;
				-- output when ready and valid
				elsif (valid_out_flag = '1') then
					for counter in STACK_SIZE-1 downto 1 loop
						stack(counter) <= stack(counter-1);
					end loop;
					stack_pointer <= stack_pointer + 1;
					ready_out <= '1';
					valid_out_flag <= '0';
					valid_out <= '0';
				elsif (ready_in = '1' and stack_pointer < STACK_SIZE-1) then
					data_out <= stack(STACK_SIZE-1);
					valid_out_flag <= '1';
					valid_out <= '1';
				else null;	
				end if;
		else null;
		end if;			
	end process;
	
end behavioral;