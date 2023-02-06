library ieee;
use ieee.std_logic_1164.ALL;
--use IEEE.STD_LOGIC_ARITH.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use std.textio.all;

entity fifo is
	generic(
		LENGTH 		: integer := 8;
		LENGTH_BITS	: integer := 3;
		DATA_WIDTH 	: integer := 8
	);
	port(
		not_enable	: IN std_logic;
		clock		: IN std_logic;
		data_in		: IN std_logic_vector(DATA_WIDTH-1 downto 0);
		data_out	: OUT std_logic_vector(DATA_WIDTH-1 downto 0);
		stack_full	: OUT std_logic := '1';
		counter_out : OUT std_logic_vector(LENGTH_BITS-1 downto 0) := (others => '0')
	);
end fifo;
	
architecture behavioral of fifo is

	type stack_t is array(0 to LENGTH-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
	signal stack 		: stack_t := (others => (others => '0')); 	

	begin
		process (clock, not_enable, data_in)
		variable i 			: integer := 0;
		variable counter 	: std_logic_vector(LENGTH_BITS-1 downto 0) := (others => '0');
		begin
			if (rising_edge(clock)) then
				if (not_enable = '0') then
					counter  := counter + 1;
					data_out <= stack(LENGTH-1);
					for i in LENGTH-1 downto 1 loop
						stack(i) <= stack(i-1);
					end loop;
					stack(0) <= data_in;
				else null;	
				end if;
				if ((to_integer(unsigned(counter)) mod LENGTH) = 0) then
					stack_full <= '1';
					counter := (others => '0');
				else
					stack_full <= '0';
				end if;
			end if;
		counter_out <= counter;
		end process;
end behavioral;
