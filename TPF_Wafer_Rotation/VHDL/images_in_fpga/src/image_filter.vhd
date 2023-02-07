library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;
use ieee.std_logic_unsigned.all;

use std.textio.all;

entity image_filter is
	generic(
		IMAGE_WIDTH 	: integer := 7;
		IMAGE_HEIGHT 	: integer := 7;
		LENGTH_BITS		: integer := 16;
		KERNEL_WIDTH 	: integer := 3;
		DATA_WIDTH		: integer := 8
		);
	port(
		clock		: IN std_logic;
		not_enable	: IN std_logic;
		pixel_in	: IN std_logic_vector(DATA_WIDTH-1 downto 0);
		filter_sel	: IN std_logic_vector(1 downto 0);
		type_sel	: IN std_logic_vector(1 downto 0);
		pixel_out	: OUT std_logic_vector(DATA_WIDTH-1 downto 0);		  
		counter_out	: OUT std_logic_vector(17 downto 0) := (others => '0');
		out_valid	: OUT std_logic := '0'
		);
end image_filter;	

architecture behavioral of image_filter is

	-- fifo component
	component fifo
	generic(
		LENGTH 		: integer := IMAGE_WIDTH-KERNEL_WIDTH;
		LENGTH_BITS	: integer := LENGTH_BITS;
		DATA_WIDTH 	: integer := DATA_WIDTH
	);
	port(
		not_enable	: IN std_logic;
		clock		: IN std_logic;
		data_in		: IN std_logic_vector(DATA_WIDTH-1 downto 0);
		data_out	: OUT std_logic_vector(DATA_WIDTH-1 downto 0);
		stack_full	: OUT std_logic;
		counter_out : OUT std_logic_vector (LENGTH_BITS-1 downto 0) := (others => '0')
	);			  
	end component;
	
	-- kernel multiply-accumulate component
	component kernel_mac
	generic(
		DATA_WIDTH		: integer := DATA_WIDTH
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
		filter_sel	: IN std_logic_vector(1 downto 0);
		sum_out		: OUT std_logic_vector(DATA_WIDTH-1 downto 0)
		);
	end component;
	
	-- erosion component
	component kernel_erosion
	generic(
		DATA_WIDTH		: integer := DATA_WIDTH
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
	end component;
	
	-- dilation component
	component kernel_dilation
	generic(
		DATA_WIDTH		: integer := DATA_WIDTH
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
	end component;

	-- product elements type
	type prod_el is array(0 to KERNEL_WIDTH-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
	
	-- internal signals
	signal prod_top : prod_el := (others => (others => '0'));
	signal prod_mid : prod_el := (others => (others => '0'));
	signal prod_bot : prod_el := (others => (others => '0'));
	
	-- pipelining signals
	signal pixel_in_reg : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
	
	signal top0_reg : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
	signal top1_reg : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
	signal top2_reg : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
	
	signal mid0_reg : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
	signal mid1_reg : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
	signal mid2_reg : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
	
	signal bot0_reg : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
	signal bot1_reg : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
	signal bot2_reg : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
	
	signal kernel_out_reg : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
	
	signal erosion_out_reg : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0'); 
	
	signal dilation_out_reg : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
	
	signal stage_3_enable : std_logic := '0';
	
	-- fifo1 signals
	signal not_enable1 	: std_logic := '1';
	signal data_in1 	: std_logic_vector(DATA_WIDTH-1 downto 0);
	signal data_out1 	: std_logic_vector(DATA_WIDTH-1 downto 0);
	signal stack_full1 	: std_logic;
	signal counter_out1 : std_logic_vector (LENGTH_BITS-1 downto 0) := (others => '0');
	
	-- fifo2 signals
	signal not_enable2 	: std_logic := '1';
	signal data_in2 	: std_logic_vector(DATA_WIDTH-1 downto 0);
	signal data_out2 	: std_logic_vector(DATA_WIDTH-1 downto 0);
	signal stack_full2 	: std_logic;
	signal counter_out2 : std_logic_vector (LENGTH_BITS-1 downto 0) := (others => '0');
	
	-- kernel mac signals
	signal kernel_not_enable : std_logic := '1';
	
	
begin
	-- fifos
	fifo1: fifo generic map (
		LENGTH => IMAGE_WIDTH-KERNEL_WIDTH,
		LENGTH_BITS	=> LENGTH_BITS,
		DATA_WIDTH => DATA_WIDTH
	)
	port map (
		not_enable => not_enable1,
		clock => clock,
		data_in	=> prod_top(2),
		data_out => prod_mid(0),
		stack_full => stack_full1,
		counter_out => counter_out1
	);
	fifo2: fifo generic map (
		LENGTH => IMAGE_WIDTH-KERNEL_WIDTH,
		LENGTH_BITS	=> LENGTH_BITS,
		DATA_WIDTH => DATA_WIDTH
	)
	port map (
		not_enable => not_enable2,
		clock => clock,
		data_in	=> prod_mid(2),
		data_out => prod_bot(0),
		stack_full => stack_full2,
		counter_out => counter_out2
	);
	
	-- kernel mac
	k_mac: kernel_mac generic map (
		DATA_WIDTH => DATA_WIDTH
	)
	port map (
		clock => clock,
		not_enable => kernel_not_enable,
		top0 => top0_reg,
		top1 => top1_reg,
		top2 => top2_reg,
		mid0 => mid0_reg,
		mid1 => mid1_reg,
		mid2 => mid2_reg,
		bot0 => bot0_reg,
		bot1 => bot1_reg,
		bot2 => bot2_reg,
		filter_sel => filter_sel,
		sum_out => kernel_out_reg
	);
	
	-- erosion
	erode: kernel_erosion generic map (
		DATA_WIDTH => DATA_WIDTH
	)
	port map (
		clock => clock,
		not_enable => kernel_not_enable,
		top0 => top0_reg,
		top1 => top1_reg,
		top2 => top2_reg,
		mid0 => mid0_reg,
		mid1 => mid1_reg,
		mid2 => mid2_reg,
		bot0 => bot0_reg,
		bot1 => bot1_reg,
		bot2 => bot2_reg,
		sum_out => erosion_out_reg
	);
	
	-- dilation
	dilate: kernel_dilation generic map (
		DATA_WIDTH => DATA_WIDTH
	)
	port map (
		clock => clock,
		not_enable => kernel_not_enable,
		top0 => top0_reg,
		top1 => top1_reg,
		top2 => top2_reg,
		mid0 => mid0_reg,
		mid1 => mid1_reg,
		mid2 => mid2_reg,
		bot0 => bot0_reg,
		bot1 => bot1_reg,
		bot2 => bot2_reg,
		sum_out => dilation_out_reg
	);
	
	-- stage 0: async enable
	Stage0: process (clock, filter_sel, not_enable)
	begin
		if (not_enable = '0') then
			not_enable1 <= '0';
			not_enable2 <= '0';
			kernel_not_enable <= '0';
		else 
			not_enable1 <= '1';
			not_enable2 <= '1';
			kernel_not_enable <= '1';
		end if;
	end process;
		
	-- stage 1: data input
	Stage1: process (clock, not_enable, pixel_in)
	begin
		if (rising_edge(clock)) then
			if (not_enable = '0') then
				pixel_in_reg <= pixel_in;
			else null;
			end if;	
		else null; 
		end if;
	end process;		
	
	-- stage 2: window and fifo shift
	Stage2:	process (clock, not_enable)
	begin
		if (rising_edge(clock)) then
			if (not_enable = '0') then
				
				prod_bot(2) <= prod_bot(1);
				prod_bot(1) <= prod_bot(0);
				--prod_bot(0) <= data_out2;
				--data_in2 <= prod_mid(2);
				prod_mid(2) <= prod_mid(1);
				prod_mid(1) <= prod_mid(0);
				--prod_mid(0) <= data_out1;
				--data_in1 <= prod_top(2);
				prod_top(2) <= prod_top(1);
				prod_top(1) <= prod_top(0);
				prod_top(0) <= pixel_in_reg;
				
				top0_reg <= prod_top(0); 
				top1_reg <= prod_top(1);
				top2_reg <= prod_top(2);
				mid0_reg <= prod_mid(0); 
				mid1_reg <= prod_mid(1);
				mid2_reg <= prod_mid(2);
				bot0_reg <= prod_bot(0); 
				bot1_reg <= prod_bot(1);
				bot2_reg <= prod_bot(2);
				
			else null;
			end if;
		else null;
		end if;
	end process;
	
	-- stage 2.5: Fifo status
	Stage2_5: process (clock, not_enable, stage_3_enable)
	variable counter : integer := 0;
	begin
		if (rising_edge(clock) and not_enable = '0' and stage_3_enable = '0') then
			counter := counter + 1;
			if (counter >= (2*IMAGE_WIDTH + KERNEL_WIDTH) + 7) then
				stage_3_enable <= '1';
			else null;
			end if;
		else null;
		end if;	
	end process;	
	
	-- stage 3: output
	Stage3: process (clock, not_enable, stage_3_enable)
	variable counter 	: integer := 0;
	variable i 		: integer := 1;
	variable j 		: integer := 0;
	begin
		if (rising_edge(clock) and (not_enable = '0') and (stage_3_enable = '1')) then		
			counter := counter + 1; 
			j := counter mod IMAGE_WIDTH; 
			if (j = 0) then
				i := i + 1;
			else null;
			end if;
			
			case type_sel is 
					when "00" => pixel_out <= kernel_out_reg;
					when "01" => pixel_out <= erosion_out_reg;	   -- type_sel = 01 => erosion
					when "10" => pixel_out <= dilation_out_reg;   -- type_sel = 10 => dilation
					when "11" => pixel_out <= kernel_out_reg;
					when others => pixel_out <= kernel_out_reg;
				end case;
			
			
			if ((j > 0) and (j < (IMAGE_WIDTH-1)) and (i > 0) and (i < (IMAGE_HEIGHT-1))) then
				out_valid <= '1';
			else 
				out_valid <= '0';
			end if;
		else null;
		end if;
	counter_out <= std_logic_vector(to_unsigned(counter, 18));
	end process;	

end behavioral;