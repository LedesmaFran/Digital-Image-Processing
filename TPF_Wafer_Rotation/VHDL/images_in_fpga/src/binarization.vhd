library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;
use std.textio.all;

entity binarization is
	generic(
		THRESHOLD	: integer := 127;
		DATA_WIDTH	: integer := 8
	);
	port(
		not_enable	: IN STD_LOGIC;
		data_in		: IN std_logic_vector ((DATA_WIDTH-1) DOWNTO 0);
		data_out	: OUT std_logic_vector ((DATA_WIDTH-1) DOWNTO 0)
	);
end binarization;

architecture behavioral of binarization is
begin
	process (not_enable, data_in)
	begin
		if (not_enable = '0') then
			if (unsigned(data_in) >= THRESHOLD) then
				data_out <= (others => '1');
			else
				data_out <= (others => '0');
			end if;
		else null; 
		end if;
	end process;	
end behavioral;
