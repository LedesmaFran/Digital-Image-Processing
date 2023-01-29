library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;
use std.textio.all;

entity kernel_mac is
	generic(
		DATA_WIDTH		: integer := 8
		);
	port(
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
		filter_sel	: IN std_logic_vector(1 downto 0);
		sum_out		: OUT std_logic_vector(DATA_WIDTH-1 downto 0)
		);
end kernel_mac;

architecture behavioral of kernel_mac is

	--products
	signal prod0 : integer := 0; 
	signal prod1 : integer := 0;
	signal prod2 : integer := 0;
	signal prod3 : integer := 0; 
	signal prod4 : integer := 0;
	signal prod5 : integer := 0;
	signal prod6 : integer := 0; 
	signal prod7 : integer := 0;
	signal prod8 : integer := 0;
	
	--sum
	signal sum : integer := 0;
	
	signal sum_signed 			: std_logic_vector(DATA_WIDTH*2-1 downto 0) := (others => '0');
	signal sum_signed_scaled 	: std_logic_vector(DATA_WIDTH*2-2 downto 0) := (others => '0');
	signal isOverflow 			: std_logic := '0';
	signal isNegative			: std_logic := '0';
	
	--kernel values
	type kernel_type is array (0 to 8) of integer;
	
	constant non_filter : kernel_type := (0,0,0,
										  0,2,0,
										  0,0,0);
	constant edge_filter : kernel_type := (-1,-1,-1,
										  -1, 8,-1,
										  -1,-1,-1);
	
	constant sharpen_filter : kernel_type := (0,-1 ,0,
											  -1,5,-1,
											  0,-1,0);
																	 
	constant custom_filter : kernel_type := (-1,0,-1,
											 0, 5, 0,
											 -1,0,-1);
																	 
																	 
	signal kernel: kernel_type;
	
	constant ceil  	: positive := (2**DATA_WIDTH)-1;
	constant floor 	: integer  := 0;
	
begin
	process (not_enable, filter_sel, top0, top1, top2, mid0, mid1, mid2, bot0, bot1, bot2)
	begin
		case filter_sel is 
				when "00" => kernel <= non_filter;
				when "01" => kernel <= edge_filter;
				when "10" => kernel <= sharpen_filter;
				when "11" => kernel <= custom_filter;
				when others => kernel <= non_filter;
			end case;
		if (not_enable = '0') then				
			
			prod0 <= to_integer(unsigned(top0)) * kernel(0);
			prod1 <= to_integer(unsigned(top1)) * kernel(1);
			prod2 <= to_integer(unsigned(top2)) * kernel(2);
			prod3 <= to_integer(unsigned(mid0)) * kernel(3);
			prod4 <= to_integer(unsigned(mid1)) * kernel(4);
			prod5 <= to_integer(unsigned(mid2)) * kernel(5);
			prod6 <= to_integer(unsigned(bot0)) * kernel(6);
			prod7 <= to_integer(unsigned(bot1)) * kernel(7);
			prod8 <= to_integer(unsigned(bot2)) * kernel(8);
			
			sum <= prod0 + prod1 + prod2 + prod3 + prod4 + prod5 + prod6 + prod7 + prod8;
			
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
	end process;
end behavioral;	