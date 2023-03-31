library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bitvector_generator is
    port (
        clk    : in  std_logic;
        rst    : in  std_logic;
        output : out std_logic_vector(3 downto 0)
    );
end entity bitvector_generator;

architecture behavioral of bitvector_generator is
    type t_bitvector_array is array(0 to 3) of std_logic_vector(3 downto 0);
    constant c_bitvectors : t_bitvector_array := ("0001", "0010", "0100", "1000");
    signal s_index         : integer range 0 to 3;
begin
    process (clk, rst)
    begin
        if rst = '1' then
            s_index <= 0;
        elsif rising_edge(clk) then
            if s_index = 3 then s_index <= 0;
            else s_index <= s_index + 1;
            end if;
        end if;
    end process;
    output <= c_bitvectors(s_index);
end architecture behavioral;