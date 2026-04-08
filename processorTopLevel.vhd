library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity processorTopLevel is
	port(clk, rst : in STD_LOGIC;
		instructionOut : out STD_LOGIC_VECTOR(31 downto 0);
		branchOut, zeroOut, memWriteOut, regWriteOut : out STD_LOGIC
	);
end entity processorTopLevel;

architecture default of processorTopLevel is

signal int_pcEn, int_pcSrc : STD_LOGIC;
signal int_pcMuxOut : STD_LOGIC_VECTOR(31 downto 0);
signal int_pcOut : STD_LOGIC_VECTOR(31 downto 0);
signal int_instructionMemOut : STD_LOGIC_VECTOR(31 downto 0);
signal int_pcPlus4 : STD_LOGIC_VECTOR(31 downto 0);
signal int_effAddress : STD_LOGIC_VECTOR(31 downto 0);

signal int_ifID_en : STD_LOGIC;
signal int_ifID_flush : STD_LOGIC;
signal int_ifID_Pipeline_Out : STD_LOGIC_VECTOR(63 downto 0); 

signal int_writeBack : STD_LOGIC_VECTOR(31 downto 0);
signal int_regWrite : STD_LOGIC;
signal int_readData1, int_readData2 : STD_LOGIC_VECTOR(31 downto 0);
signal int_signExtOut : STD_LOGIC_VECTOR(31 downto 0);
signal int_signExtShifted : STD_LOGIC_VECTOR(31 downto 0);

signal int_regDst, int_jump, int_branch : STD_LOGIC;
signal int_memRead, int_memToReg : STD_LOGIC;
signal int_aluOp : STD_LOGIC_VECTOR(1 downto 0);
signal int_memWrite, int_aluSrc : STD_LOGIC;
signal int_regWriteCtrl : STD_LOGIC;

signal int_idEX_en : STD_LOGIC;
signal int_idEX_Pipeline_In : STD_LOGIC_VECTOR(152 downto 0);
signal int_idEX_Pipeline_Out : STD_LOGIC_VECTOR(152 downto 0);

signal int_aluResult : STD_LOGIC_VECTOR(31 downto 0);
signal int_aluCtrl : STD_LOGIC_VECTOR(2 downto 0);
signal int_aluSrcMuxOut : STD_LOGIC_VECTOR(31 downto 0);
signal int_regDstMuxOut : STD_LOGIC_VECTOR(4 downto 0);
signal int_fwdA, int_fwdB : STD_LOGIC_VECTOR(1 downto 0);
signal int_fwdAMuxOut, int_fwdBMuxOut : STD_LOGIC_VECTOR(31 downto 0);
signal int_zero : STD_LOGIC;

signal int_exMEM_en : STD_LOGIC;
signal int_exMEM_Pipeline_In : STD_LOGIC_VECTOR(106 downto 0);
signal int_exMEM_Pipeline_Out : STD_LOGIC_VECTOR(106 downto 0);

signal int_dataMemOut : STD_LOGIC_VECTOR(31 downto 0);
signal int_branchTaken : STD_LOGIC;

signal int_memWB_en : STD_LOGIC;
signal int_memWB_Pipeline_In : STD_LOGIC_VECTOR(70 downto 0);
signal int_memWB_Pipeline_Out : STD_LOGIC_VECTOR(70 downto 0);

signal int_stall, int_idFlush : STD_LOGIC;

signal int_wbRegDst : STD_LOGIC_VECTOR(4 downto 0);

component InstMem
    PORT (
        address : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
        clock   : IN STD_LOGIC := '1';
        q       : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
    );
end component;

component DataMem
    PORT (
        clock     : IN STD_LOGIC := '1';
        data      : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
        rdaddress : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
        rden      : IN STD_LOGIC := '1';
        wraddress : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
        wren      : IN STD_LOGIC := '0';
        q         : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
    );
end component;

component nBit_fullAdder
    generic (n : integer := 8);
    port (
        cin       : in STD_LOGIC;
        x, y      : in STD_LOGIC_VECTOR(n-1 downto 0);
        cMSB, cOut: out STD_LOGIC;
        sum       : out STD_LOGIC_VECTOR(n-1 downto 0)
    );
end component;

component mux_2to1_nBit
    generic (N : integer := 8);
    port (
        i_a   : in  std_logic_vector(N-1 downto 0);
        i_b   : in  std_logic_vector(N-1 downto 0);
        i_sel : in  std_logic;
        o_y   : out std_logic_vector(N-1 downto 0)
    );
end component;

component mux_4to1_nBit
    generic (N : integer := 32);
    port (
        i_a   : in  std_logic_vector(N-1 downto 0);
        i_b   : in  std_logic_vector(N-1 downto 0);
        i_c   : in  std_logic_vector(N-1 downto 0);
        i_d   : in  std_logic_vector(N-1 downto 0);
        i_sel : in  std_logic_vector(1 downto 0);
        o_y   : out std_logic_vector(N-1 downto 0)
    );
end component;

component ifID_Pipeline
    port (
        clk, rst, en : in STD_LOGIC;
        flush        : in STD_LOGIC;
        inputs       : in STD_LOGIC_VECTOR(63 downto 0);
        outputs      : out STD_LOGIC_VECTOR(63 downto 0)
    );
end component;

component idEX_Pipeline
    port (
        clk, rst, en : in STD_LOGIC;
        inputs       : in STD_LOGIC_VECTOR(152 downto 0);
        outputs      : out STD_LOGIC_VECTOR(152 downto 0)
    );
end component;

component exMEM_Pipeline
    port (
        clk, rst, en : in STD_LOGIC;
        inputs       : in STD_LOGIC_VECTOR(106 downto 0);
        outputs      : out STD_LOGIC_VECTOR(106 downto 0)
    );
end component;

component memWB_Pipeline
    port (
        clk, rst, en : in STD_LOGIC;
        inputs       : in STD_LOGIC_VECTOR(70 downto 0);
        outputs      : out STD_LOGIC_VECTOR(70 downto 0)
    );
end component;

component hdu
    port (
        clk, rst       : in STD_LOGIC;
        idEX_memRead   : in STD_LOGIC;
        idEX_rt        : in STD_LOGIC_VECTOR(4 downto 0);
        ifID_rs        : in STD_LOGIC_VECTOR(4 downto 0);
        ifID_rt        : in STD_LOGIC_VECTOR(4 downto 0);
        branch, jump   : in STD_LOGIC;
        stall, idFlush : out STD_LOGIC
    );
end component;

component controlUnit
    port (
        i_opcode   : in  std_logic_vector(5 downto 0);
        o_regDst   : out std_logic;
        o_jump     : out std_logic;
        o_branch   : out std_logic;
        o_memRead  : out std_logic;
        o_memToReg : out std_logic;
        o_aluOp    : out std_logic_vector(1 downto 0);
        o_memWrite : out std_logic;
        o_aluSrc   : out std_logic;
        o_regWrite : out std_logic
    );
end component;

component shiftLeft2_32x32
    port (
        i_value : in STD_LOGIC_VECTOR(31 downto 0);
        o_value : out STD_LOGIC_VECTOR(31 downto 0)
    );
end component;

component signExtend
    port (
        i_16 : in  std_logic_vector(15 downto 0);
        o_32 : out std_logic_vector(31 downto 0)
    );
end component;

component aluTopLevel
    port (
        x, y      : in STD_LOGIC_VECTOR(31 downto 0);
        aluOP     : in STD_LOGIC_VECTOR(2 downto 0);
        aluResult : out STD_LOGIC_VECTOR(31 downto 0);
        zero      : out STD_LOGIC
    );
end component;

component forwardingUnit
    port (
        exMEM_rd       : in STD_LOGIC_VECTOR(4 downto 0);
        idEX_rs        : in STD_LOGIC_VECTOR(4 downto 0);
        idEX_rt        : in STD_LOGIC_VECTOR(4 downto 0);
        memWB_rd       : in STD_LOGIC_VECTOR(4 downto 0);
        memWB_regWrite : in STD_LOGIC;
        exMEM_regWrite : in STD_LOGIC;
        fwdA, fwdB     : out STD_LOGIC_VECTOR(1 downto 0)
    );
end component;

component aluControl
    port (
        i_aluOp   : in  std_logic_vector(1 downto 0);
        i_funct   : in  std_logic_vector(5 downto 0);
        o_aluCtrl : out std_logic_vector(2 downto 0)
    );
end component;

component registerFile
    port (
        readRegister1, readRegister2 : in STD_LOGIC_VECTOR(4 downto 0);
        writeRegister                : in STD_LOGIC_VECTOR(4 downto 0);
        writeData                    : in STD_LOGIC_VECTOR(31 downto 0);
        regWrite                     : in STD_LOGIC;
        clk, rst                     : in STD_LOGIC;
        readData1, readData2         : out STD_LOGIC_VECTOR(31 downto 0)
    );
end component;

component reg_n_bit_en
    generic (N : integer := 8);
    port (
        i_clk    : in  std_logic;
        i_reset  : in  std_logic;
        i_enable : in  std_logic;
        i_d      : in  std_logic_vector(N-1 downto 0);
        o_q      : out std_logic_vector(N-1 downto 0)
    );
end component;

begin 

int_pcEn <= not int_stall;

pc : reg_n_bit_en
    generic map (N => 32)
    port map (
        i_clk    => clk,
        i_reset  => rst,
        i_enable => int_pcEn,
        i_d      => int_pcMuxOut,
        o_q      => int_pcOut
    );

instructionMemory : InstMem
    port map (
        address => int_pcOut(9 downto 2),
        clock   => clk,
        q       => int_instructionMemOut
    );

pcAdder : nBit_fullAdder
    generic map (n => 32)
    port map (
        cin  => '0',
        x    => int_pcOut,
        y    => X"00000004",
        cMSB => open,
        cOut => open,
        sum  => int_pcPlus4
    );

int_pcSrc <= int_branchTaken;

pcMux : mux_2to1_nBit
    generic map (N => 32)
    port map (
        i_a   => int_pcPlus4,
        i_b   => int_effAddress,
        i_sel => int_pcSrc,
        o_y   => int_pcMuxOut
    );

int_ifID_en <= not int_stall;
int_ifID_flush <= int_branchTaken;

ifIdPipeline : ifID_Pipeline
    port map (
        clk     => clk,
        rst     => rst,
        en      => int_ifID_en,
        flush   => int_ifID_flush,
        inputs  => int_pcPlus4 & int_instructionMemOut,
        outputs => int_ifID_Pipeline_Out
    );

control : controlUnit
    port map (
        i_opcode   => int_ifID_Pipeline_Out(31 downto 26),
        o_regDst   => int_regDst,
        o_jump     => int_jump,
        o_branch   => int_branch,
        o_memRead  => int_memRead,
        o_memToReg => int_memToReg,
        o_aluOp    => int_aluOp,
        o_memWrite => int_memWrite,
        o_aluSrc   => int_aluSrc,
        o_regWrite => int_regWriteCtrl
    );

registers : registerFile
    port map (
        readRegister1 => int_ifID_Pipeline_Out(25 downto 21),
        readRegister2 => int_ifID_Pipeline_Out(20 downto 16),
        writeRegister => int_wbRegDst,
        writeData     => int_writeBack,
        regWrite      => int_regWrite,
        clk           => clk,
        rst           => rst,
        readData1     => int_readData1,
        readData2     => int_readData2
    );

signExtender : signExtend
    port map (
        i_16 => int_ifID_Pipeline_Out(15 downto 0),
        o_32 => int_signExtOut
    );

hazardUnit : hdu
    port map (
        clk          => clk,
        rst          => rst,
        idEX_memRead => int_idEX_Pipeline_Out(152),
        idEX_rt      => int_idEX_Pipeline_Out(4 downto 0),
        ifID_rs      => int_ifID_Pipeline_Out(25 downto 21),
        ifID_rt      => int_ifID_Pipeline_Out(20 downto 16),
        branch       => int_branch,
        jump         => int_jump,
        stall        => int_stall,
        idFlush      => int_idFlush
    );

int_idEX_en <= '1';

int_idEX_Pipeline_In <= int_memRead &                                -- [152]
                        (int_regWriteCtrl and not int_idFlush) &     -- [151]
                        int_memToReg &                               -- [150]
                        int_branch &                                 -- [149]
                        (int_memWrite and not int_idFlush) &         -- [148]
                        int_aluOp &                                  -- [147:146]
                        int_aluSrc &                                 -- [145]
                        int_regDst &                                 -- [144]
                        int_ifID_Pipeline_Out(63 downto 32) &        -- [143:112] PC+4
                        int_readData1 &                              -- [111:80]
                        int_readData2 &                              -- [79:48]
                        int_signExtOut &                             -- [47:16]
                        int_ifID_Pipeline_Out(25 downto 21) &        -- [15:11] rs
                        int_ifID_Pipeline_Out(20 downto 16) &        -- [10:6] rt
                        int_ifID_Pipeline_Out(15 downto 11) &        -- [5:1] rd
                        '0';                                         -- [0] PADDING BIT
idExPipeline : idEX_Pipeline
    port map (
        clk     => clk,
        rst     => rst,
        en      => int_idEX_en,
        inputs  => int_idEX_Pipeline_In,
        outputs => int_idEX_Pipeline_Out
    );

fwdUnit : forwardingUnit
    port map (
        exMEM_rd       => int_exMEM_Pipeline_Out(4 downto 0),
        idEX_rs        => int_idEX_Pipeline_Out(15 downto 11),
        idEX_rt        => int_idEX_Pipeline_Out(10 downto 6),
        memWB_rd       => int_memWB_Pipeline_Out(4 downto 0),
        memWB_regWrite => int_memWB_Pipeline_Out(70),
        exMEM_regWrite => int_exMEM_Pipeline_Out(106),
        fwdA           => int_fwdA,
        fwdB           => int_fwdB
    );

fwdAMux : mux_4to1_nBit
    generic map (N => 32)
    port map (
        i_a   => int_idEX_Pipeline_Out(111 downto 80),
        i_b   => int_writeBack,
        i_c   => int_exMEM_Pipeline_Out(68 downto 37),
        i_d   => (others => '0'),
        i_sel => int_fwdA,
        o_y   => int_fwdAMuxOut
    );

fwdBMux : mux_4to1_nBit
    generic map (N => 32)
    port map (
        i_a   => int_idEX_Pipeline_Out(79 downto 48),
        i_b   => int_writeBack,
        i_c   => int_exMEM_Pipeline_Out(68 downto 37),
        i_d   => (others => '0'),
        i_sel => int_fwdB,
        o_y   => int_fwdBMuxOut
    );

aluSrcMux : mux_2to1_nBit
    generic map (N => 32)
    port map (
        i_a   => int_fwdBMuxOut,
        i_b   => int_idEX_Pipeline_Out(47 downto 16),
        i_sel => int_idEX_Pipeline_Out(145),
        o_y   => int_aluSrcMuxOut
    );

aluCtrl : aluControl
    port map (
        i_aluOp   => int_idEX_Pipeline_Out(147 downto 146),
        i_funct   => int_idEX_Pipeline_Out(21 downto 16),
        o_aluCtrl => int_aluCtrl
    );

alu : aluTopLevel
    port map (
        x         => int_fwdAMuxOut,
        y         => int_aluSrcMuxOut,
        aluOP     => int_aluCtrl,
        aluResult => int_aluResult,
        zero      => int_zero
    );

regDstMux : mux_2to1_nBit
    generic map (N => 5)
    port map (
        i_a   => int_idEX_Pipeline_Out(10 downto 6),
        i_b   => int_idEX_Pipeline_Out(5 downto 1),
        i_sel => int_idEX_Pipeline_Out(144),
        o_y   => int_regDstMuxOut
    );

branchShift : shiftLeft2_32x32
    port map (
        i_value => int_idEX_Pipeline_Out(47 downto 16),
        o_value => int_signExtShifted
    );

branchAdder : nBit_fullAdder
    generic map (n => 32)
    port map (
        cin  => '0',
        x    => int_idEX_Pipeline_Out(143 downto 112),
        y    => int_signExtShifted,
        cMSB => open,
        cOut => open,
        sum  => int_effAddress
    );

int_exMEM_en <= '1';

int_exMEM_Pipeline_In <= int_idEX_Pipeline_Out(151) &
                         int_idEX_Pipeline_Out(150) &
                         int_idEX_Pipeline_Out(149) &
                         int_idEX_Pipeline_Out(148) &
                         int_idEX_Pipeline_Out(152) &
                         int_zero &
                         int_effAddress &
                         int_aluResult &
                         int_fwdBMuxOut &
                         int_regDstMuxOut;

exMemPipeline : exMEM_Pipeline
    port map (
        clk     => clk,
        rst     => rst,
        en      => int_exMEM_en,
        inputs  => int_exMEM_Pipeline_In,
        outputs => int_exMEM_Pipeline_Out
    );

int_branchTaken <= int_exMEM_Pipeline_Out(104) and int_exMEM_Pipeline_Out(101);

dataMemory : DataMem
    port map (
        clock     => clk,
        data      => int_exMEM_Pipeline_Out(36 downto 5),
        rdaddress => int_exMEM_Pipeline_Out(44 downto 37),
        rden      => int_exMEM_Pipeline_Out(102),
        wraddress => int_exMEM_Pipeline_Out(44 downto 37),
        wren      => int_exMEM_Pipeline_Out(103),
        q         => int_dataMemOut
    );

int_memWB_en <= '1';

int_memWB_Pipeline_In <= int_exMEM_Pipeline_Out(106) &
                         int_exMEM_Pipeline_Out(105) &
                         int_dataMemOut &
                         int_exMEM_Pipeline_Out(68 downto 37) &
                         int_exMEM_Pipeline_Out(4 downto 0);

memWbPipeline : memWB_Pipeline
    port map (
        clk     => clk,
        rst     => rst,
        en      => int_memWB_en,
        inputs  => int_memWB_Pipeline_In,
        outputs => int_memWB_Pipeline_Out
    );

wbMux : mux_2to1_nBit
    generic map (N => 32)
    port map (
        i_a   => int_memWB_Pipeline_Out(36 downto 5),
        i_b   => int_memWB_Pipeline_Out(68 downto 37),
        i_sel => int_memWB_Pipeline_Out(69),
        o_y   => int_writeBack
    );

int_regWrite <= int_memWB_Pipeline_Out(70);
int_wbRegDst <= int_memWB_Pipeline_Out(4 downto 0);

instructionOut <= int_ifID_Pipeline_Out(31 downto 0);
branchOut      <= int_branchTaken;
zeroOut        <= int_exMEM_Pipeline_Out(101);
memWriteOut    <= int_exMEM_Pipeline_Out(103);
regWriteOut    <= int_regWrite;

end architecture default;