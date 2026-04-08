library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity reg_n_bit_en is
    generic (
        N : integer := 8
    );
    port (
        i_clk    : in  std_logic;
        i_reset  : in  std_logic;
        i_enable : in  std_logic;
        i_d      : in  std_logic_vector(N-1 downto 0);
        o_q      : out std_logic_vector(N-1 downto 0)
    );
end entity reg_n_bit_en;

architecture structural of reg_n_bit_en is
    component d_flip_flop_en is
        port (
            i_clk    : in  std_logic;
            i_reset  : in  std_logic;
            i_enable : in  std_logic;
            i_d      : in  std_logic;
            o_q      : out std_logic;
            o_qn     : out std_logic
        );
    end component;
begin
    GEN_REG: for i in 0 to N-1 generate
        DFF_INST: d_flip_flop_en
            port map (
                i_clk    => i_clk,
                i_reset  => i_reset,
                i_enable => i_enable,
                i_d      => i_d(i),
                o_q      => o_q(i),
                o_qn     => open
            );
    end generate GEN_REG;
end architecture structural;
