library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity forwardingUnit is
	port( clk, rst : in STD_LOGIC;
		 exMEM_rd, idEX_rs, idEX_rt, memWB_rd : in STD_LOGIC_VECTOR(31 downto 0);
		 memWB_regWrite, exMEM_regWrite : in STD_LOGIC;
		 fwdA, fwdB : out STD_LOGIC_VECTOR(1 downto 0)
	);
end entity forwardingUnit;

architecture default of forwardingUnit is

signal int_fwdA, int_fwdB : STD_LOGIC_VECTOR(1 downto 0);
signal int_NE, int_EQ : STD_LOGIC_VECTOR(5 downto 0);

component comparator_nBit
	generic( n : integer := 8
	);
	port( x, y : in STD_LOGIC_VECTOR(n-1 downto 0);
		eq, ne : out STD_LOGIC
	);
end component;

begin

comp0 : comparator_nBit
	generic map( n => 32
	)port map( x => exMEM_rd,
		y => "00000000000000000000000000000000",
		eq => int_EQ(0),
		ne => int_NE(0)
	);
	
comp1 : comparator_nBit
	generic map( n => 32
	)port map( x => exMEM_rd,
		y => idEX_rs,
		eq => int_EQ(1),
		ne => int_NE(1)
	);

comp2 : comparator_nBit
	generic map( n => 32
	)port map( x => exMEM_rd,
		y => idEX_rt,
		eq => int_EQ(2),
		ne => int_NE(2)
	);
	
comp3 : comparator_nBit
	generic map( n => 32
	)port map( x => memWB_rd,
		y => idEX_rs,
		eq => int_EQ(3),
		ne => int_NE(3)
	);

comp4 : comparator_nBit
	generic map( n => 32
	)port map( x => memWB_rd,
		y => "00000000000000000000000000000000",
		eq => int_EQ(4),
		ne => int_NE(4)
	);
	
comp5 : comparator_nBit
	generic map( n => 32
	)port map( x => memWB_rd,
		y => idEX_rt,
		eq => int_EQ(5),
		ne => int_NE(5)
	);

fwdA(0) <= memWB_regWrite and int_EQ(3) and int_NE(4);
fwdA(1) <= exMEM_regWrite and int_NE(0) and int_EQ(1);
fwdB(0) <= memWB_regWrite and int_EQ(5) and int_NE(4);
fwdB(1) <= exMEM_regWrite and int_NE(0) and int_EQ(2);

end architecture default;