Library IEEE;
use IEEE.std_logic_1164.all;


entity reg is
	generic(
		DATA_WIDTH : integer := 8
	);
	port(
		signal reg_input :in  std_logic_vector(DATA_WIDTH-1 downto 0) ;
		signal reset: in std_logic;
		signal clock: in std_logic;
		signal reg_output: out std_logic_vector(DATA_WIDTH-1 downto 0)
	 );
end reg;

architecture behavioral of reg is
begin
	process (clock)
	begin
		if (rising_edge(clock)) then
			if (reset='1') then
				reg_output <= "00000000";
			else
				reg_output <= reg_input;
			end if;
		end if;
	end process;
end behavioral;