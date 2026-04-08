library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity subtractor is
	port( x, y : in STD_LOGIC_VECTOR(6 downto 0);
		d : out STD_LOGIC_VECTOR(6 downto 0);
		ld, clk, rst : in STD_LOGIC
	);
end entity subtractor;

architecture default of subtractor is

	signal int_carryOut, int_carryIn : STD_LOGIC_VECTOR(6 downto 0);
	signal int_x, int_y : STD_LOGIC_VECTOR(6 downto 0);
	signal int_d : STD_LOGIC_VECTOR(6 downto 0);
	
	component one_bit_full_adder
		port( a, b : in STD_LOGIC;
			cin : in STD_LOGIC;
			s : out STD_LOGIC;
			cout : out STD_LOGIC
		);
	end component;
	
	component reg_n_bit_en
		generic (
        N : INTEGER := 8
		);
		port (
        i_clk    : in  STD_LOGIC;
        i_reset  : in  STD_LOGIC;
        i_enable : in  STD_LOGIC;
        i_d      : in  STD_LOGIC_VECTOR(N-1 downto 0);
        o_q      : out STD_LOGIC_VECTOR(N-1 downto 0)
		);
	end component;
	
	begin
	
		xRegister : reg_n_bit_en
			generic map( N => 7
			)
			port map( i_clk => clk,
				i_reset => rst,
				i_enable => ld,
				i_d => x,
				o_q => int_x
			);
			
		yRegister : reg_n_bit_en
			generic map( N => 7
			)
			port map( i_clk => clk,
				i_reset => rst,
				i_enable => ld,
				i_d => y,
				o_q => int_y
			);
		
		gen_FullAdders : for i in 0 to 6 generate
		
			fullAdder_inst : one_bit_full_adder
				port map( a => int_x(i),
					b => not int_y(i),
					cin => int_carryIn(i),
					s => int_d(i),
					cout => int_carryOut(i)
				);
		end generate gen_fullAdders;
		
		int_carryIn(0) <= '1';
		int_carryIn(1) <= int_carryOut(0);
		int_carryIn(2) <= int_carryOut(1);
		int_carryIn(3) <= int_carryOut(2);
		int_carryIn(4) <= int_carryOut(3);
		int_carryIn(5) <= int_carryOut(4);
		int_carryIn(6) <= int_carryOut(5);
		
		d <= int_d;
end architecture default;
	