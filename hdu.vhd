library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity hdu is
	port( clk, rst, en : in STD_LOGIC;
		idEX_memRead : in STD_LOGIC;
		idEX_rt : in STD_LOGIC_VECTOR(31 downto 0);
		ifID_rs : in STD_LOGIC_VECTOR(31 downto 0);
		ifID_rt : in STD_LOGIC_VECTOR(31 downto 0);
		branch, jump : in STD_LOGIC;
		stall, idFlush : out STD_LOGIC
	);
end entity hdu;

architecture default of hdu is

signal int_ifFlush : STD_LOGIC;
signal int_eq : STD_LOGIC_VECTOR(2 downto 0);

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
	)port map( x => idEX_rt,
		y => ifID_rs,
		eq=> int_eq(0),
		ne => open
	);

comp1 : comparator_nBit
	generic map( n => 32
	)port map( x => idEX_rt,
		y => ifID_rt,
		eq=> int_eq(1),
		ne => open
	);

comp2 : comparator_nBit
	generic map( n => 32
	)port map( x => ifID_rt,
		y => ifID_rs,
		eq=> int_eq(2),
		ne => open
	);

stall <= idEX_memRead and (int_eq(0) or int_eq(1));
idFlush <= int_eq(2) and (branch or jump);

end architecture default;
	