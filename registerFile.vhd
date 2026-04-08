library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.vector_Array_Pkg.all;

entity registerFile is
	port( readRegister1, readRegister2 : in STD_LOGIC_VECTOR(4 downto 0);
		writeRegister : in STD_LOGIC_VECTOR(4 downto 0);
		writeData : in STD_LOGIC_VECTOR(31 downto 0);
		regWrite : in STD_LOGIC;
		clk, rst : in STD_LOGIC;
		readData1, readData2 : out STD_LOGIC_VECTOR(31 downto 0)
	);
end entity;

architecture default of registerFile is
	
	signal int_decoderOut : STD_LOGIC_VECTOR(31 downto 0);
	signal int_regOut : array_8x32;
	signal int_readData1, int_readData2 : STD_LOGIC_VECTOR(31 downto 0);
	
	component mux_8to3_32Bit
		port( 
        inputs : in array_8x32;
        sel    : in STD_LOGIC_VECTOR(2 downto 0);
        output : out STD_LOGIC_VECTOR(31 downto 0)
		);
	 end component;
	 
	component decoder_5_to_32
		port(writeAddr : in STD_LOGIC_VECTOR(4 downto 0);
			decoderOut : out STD_LOGIC_VECTOR(31 downto 0)
		);
	end component;
	
	component reg_n_bit_fallingEdge
		generic (
        N : integer := 8    -- Default width is 8 bits
		);
		port (
        i_clk   : in  std_logic;
		  i_en : in std_logic;
        i_reset : in  std_logic;
        i_d     : in  std_logic_vector(N-1 downto 0);
        o_q     : out std_logic_vector(N-1 downto 0)
		);
	end component;
	
	begin
	
	addressDecoder : decoder_5_to_32
		port map(writeAddr => writeRegister,
			decoderOut => int_decoderOut
		);
	
	mux1 : mux_8to3_32Bit
	port map( inputs => int_regOut,
		sel => readRegister1(2 downto 0),
		output => readData1
	);
	
	mux2 : mux_8to3_32Bit
	port map( inputs => int_regOut,
		sel => readRegister2(2 downto 0),
		output => readData2
	);
	
	reg_zero : reg_n_bit_fallingEdge
		generic map( N => 32 )
      port map( 
            i_clk   => clk,
            i_reset => rst,
            -- ONLY enable if regWrite is '1' AND this specific decoder bit is '1'
            i_en    => '0',
            i_d     => writeData,
            o_q     => int_regOut(0)
        );
	
	gen_registers : for i in 1 to 7 generate
    reg_inst : reg_n_bit_fallingEdge
        generic map( N => 32 )
        port map( 
            i_clk   => clk,
            i_reset => rst,
            -- ONLY enable if regWrite is '1' AND this specific decoder bit is '1'
            i_en    => (regWrite and int_decoderOut(i)), 
            i_d     => writeData,
            o_q     => int_regOut(i)
        );
	end generate gen_registers;

end architecture default;
	
	
		
	
	
	