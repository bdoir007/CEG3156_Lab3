library ieee;
use ieee.std_logic_1164.all;

entity one_bit_full_adder is
	port( a, b : in STD_LOGIC;
		cin : in STD_LOGIC;
		s : out STD_LOGIC;
		cout : out STD_LOGIC
	);
end entity one_bit_full_adder;

architecture default of one_bit_full_adder is
	signal int_xor : STD_LOGIC_VECTOR (1 downto 0);
	signal int_and : STD_LOGIC_VECTOR(1 downto 0);
	signal int_or : STD_LOGIC;
	
	begin
	
		int_xor(0) <= a xor b;
		int_xor(1) <= int_xor(0) xor cin;
		int_and(0) <= a and b;
		int_and(1) <= int_xor(0) and cin;
		int_or <= int_and(1) or int_and(0);
		
		s <= int_xor(1);
		cout <= int_or;
	
end architecture default;