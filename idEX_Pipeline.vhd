library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity idEX_Pipeline is
	port(clk, rst, en : in STD_LOGIC;
		inputs : in STD_LOGIC_VECTOR(147 downto 0);
		outputs : out STD_LOGIC_VECTOr(147 downto 0)
	);
end entity idEX_Pipeline;

architecture default of idEX_Pipeline is

signal int_outputs : STD_LOGIC_VECTOR(147 downto 0);

component nbit_register
		generic (
        N : integer := 8    -- Default width is 8 bits
    );
    port (
        i_clk   : in  std_logic;
        i_reset : in  std_logic;
		  i_en : in std_logic;
        i_d     : in  std_logic_vector(N-1 downto 0);
        o_q     : out std_logic_vector(N-1 downto 0)
    );
	end component; 

begin

reg : nbit_register
	generic map(n => 148)
	port map( i_clk => clk,
		i_reset => rst,
		i_en => en,
		i_d => inputs,
		o_q => int_outputs
	);

	outputs <= int_outputs;
	
end architecture default;