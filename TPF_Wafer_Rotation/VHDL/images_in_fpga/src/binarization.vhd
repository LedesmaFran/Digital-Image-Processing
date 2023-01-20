library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;
use std.textio.all;

entity binarization is
	generic(
		THRESHOLD	: integer := 127;
		DATA_WIDTH	: integer  := 8
	);
	port(
		not_enable	: IN STD_LOGIC;
		clock		: IN STD_LOGIC;
		data_in		: IN std_logic_vector ((DATA_WIDTH-1) DOWNTO 0);
		data_out	: OUT std_logic_vector ((DATA_WIDTH-1) DOWNTO 0)
	);
end binarization;

architecture behavioral of binarization is

begin
	process (clock)
	begin
		if (rising_edge(clock)) then
			if (not_enable = '0') then
				if (unsigned(data_in) >= THRESHOLD) then
					data_out <= x"ff";
				else
					data_out <= x"00";
				end if;
			end if;
		end if;
	end process;	
end behavioral;
