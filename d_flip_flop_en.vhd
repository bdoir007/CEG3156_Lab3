library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity d_flip_flop_en is
    port (
        i_clk    : in  std_logic;
        i_reset  : in  std_logic;
        i_enable : in  std_logic; 
        i_d      : in  std_logic;
        o_q      : out std_logic;
        o_qn     : out std_logic
    );
end entity d_flip_flop_en;

architecture behavioral of d_flip_flop_en is
    signal s_q : std_logic := '0';
begin
    process(i_clk)
    begin
        if rising_edge(i_clk) then
            if i_reset = '1' then
                s_q <= '0';
            elsif i_enable = '1' then
                s_q <= i_d;
            end if;
        end if;
    end process;
    
    o_q  <= s_q;
    o_qn <= not s_q;
end architecture behavioral;
