library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity reg_n_bit_fallingEdge is
    generic (
        N : integer := 8
    );
    port (
        i_clk    : in  std_logic;
        i_reset  : in  std_logic;
        i_en : in  std_logic;
        i_d      : in  std_logic_vector(N-1 downto 0);
        o_q      : out std_logic_vector(N-1 downto 0)
    );
end entity reg_n_bit_fallingEdge;

architecture structural of reg_n_bit_fallingEdge is
    component fallingEdgeDff is
        port (
            i_clk    : in  std_logic;
            i_reset  : in  std_logic;
            i_en : in  std_logic;
            i_d      : in  std_logic;
            o_q      : out std_logic;
            o_qn     : out std_logic
        );
    end component;
begin
    GEN_REG: for i in 0 to N-1 generate
        DFF_INST: fallingEdgeDff
            port map (
                i_clk    => i_clk,
                i_reset  => i_reset,
                i_en => i_en,
                i_d      => i_d(i),
                o_q      => o_q(i),
                o_qn     => open
            );
    end generate GEN_REG;
end architecture structural;
