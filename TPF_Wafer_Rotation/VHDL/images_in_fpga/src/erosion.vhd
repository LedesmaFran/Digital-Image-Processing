library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;
use std.textio.all;

entity kernel_erosion is
	generic(
		DATA_WIDTH		: integer := 8
		);
	port(
		clock		: IN std_logic;
		not_enable	: IN std_logic;
		top0		: IN std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
		top1		: IN std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
		top2		: IN std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
		mid0		: IN std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
		mid1		: IN std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
		mid2		: IN std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
		bot0		: IN std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
		bot1		: IN std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
		bot2		: IN std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
		sum_out		: OUT std_logic_vector(DATA_WIDTH-1 downto 0)
		);
end kernel_erosion;

architecture behavioral of kernel_erosion is

	--products
	signal prod0 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0'); 
	signal prod1 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
	signal prod2 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
	signal prod3 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
	signal prod4 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
	signal prod5 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
	signal prod6 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0'); 
	signal prod7 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
	signal prod8 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
	
	--sum
	signal sum : integer := 0;
	
	signal sum_signed 			: std_logic_vector(DATA_WIDTH*2-1 downto 0) := (others => '0');
	signal sum_signed_scaled 	: std_logic_vector(DATA_WIDTH*2-2 downto 0) := (others => '0');
	signal isOverflow 			: std_logic := '0';
	signal isNegative			: std_logic := '0';
	
	--kernel values
	type kernel_type is array (0 to 8) of std_logic_vector(DATA_WIDTH-1 downto 0);
	
	constant erosion_filter : kernel_type := ((others => '0'),(others => '1'),(others => '0'),
										  	  (others => '1'),(others => '1'),(others => '1'),
										  	  (others => '0'),(others => '1'),(others => '0'));
	
	constant ceil  	: positive := (2**DATA_WIDTH)-1;
	constant floor 	: integer  := 0;
	
begin
	process (clock, not_enable, top0, top1, top2, mid0, mid1, mid2, bot0, bot1, bot2)
	begin
		if (rising_edge(clock)) then			
			if (not_enable = '0') then
				
				-- erosion
				prod0 <= top0 and erosion_filter(0);
				prod1 <= top1 and erosion_filter(1);
				prod2 <= top2 and erosion_filter(2);
				prod3 <= mid0 and erosion_filter(3);
				prod4 <= mid1 and erosion_filter(4);
				prod5 <= mid2 and erosion_filter(5);
				prod6 <= bot0 and erosion_filter(6);
				prod7 <= bot1 and erosion_filter(7);
				prod8 <= bot2 and erosion_filter(8);
				
				sum <= to_integer(unsigned(prod1 and prod3 and prod4 and prod5 and prod7));
				
				sum_signed <= std_logic_vector(to_signed(sum, (DATA_WIDTH*2)));
		
				--divide by two
				sum_signed_scaled <= sum_signed((DATA_WIDTH*2)-1 downto 1);
				
				
				--check if number is between floor and ceil, set to floor if less than floor, set to ceil if greater than ceil 
				if (signed(sum_signed_scaled) > ceil) then
					isOverflow <= '1';
				else 
					isOverflow <= '0';
				end if;
				if (signed(sum_signed_scaled) < floor) then
					isNegative <= '1';
				else 
					isNegative <= '0';
				end if;
				
				if ( isOverflow = '0' and isNegative = '0') then
					sum_out <= sum_signed_scaled(DATA_WIDTH-1 downto 0);
				elsif (isOverflow = '1' and isNegative = '0') then
					sum_out <= std_logic_vector(to_unsigned(ceil, DATA_WIDTH));
				elsif (isOverflow = '0' and isNegative = '1') then
					sum_out <= std_logic_vector(to_unsigned(floor, DATA_WIDTH));
				else 
					sum_out <= sum_signed_scaled(DATA_WIDTH-1  downto 0);
				end if;	
			else null;
			end if;
		else null;
	end if;
	end process;
end behavioral;	