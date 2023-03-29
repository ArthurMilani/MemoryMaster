-----------------Laboratorio Digital-------------------------------------
-- Arquivo   : contador_m_decre.vhd
-- Projeto   : Experiencia 4 - Desenvolvimento de Projeto de 
--                             Circuitos Digitais em FPGA
-------------------------------------------------------------------------
-- Descricao : contador binario, modulo m, com parametro M generic,
--             sinais para clear assincrono (zera_as) e sincrono (zera_s)
--             e saidas de fim e meio de contagem
-- 
--             calculo do numero de bits do contador em funcao do modulo:
--             N = natural(ceil(log2(real(M))))
--
-- Exemplo de instanciacao: contador módulo 50
--             CONT50: contador_m_decre 
--                     generic map ( M=> 50 )
--                     port map ( ...
--             
-------------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     09/09/2019  1.0     Edson Midorikawa  criacao
--     08/06/2020  1.1     Edson Midorikawa  revisao e melhoria de codigo 
--     09/09/2020  1.2     Edson Midorikawa  revisao 
--     30/01/2022  2.0     Edson Midorikawa  revisao do componente
--     29/01/2023  2.1     Edson Midorikawa  revisao do componente
-------------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity contador_m_decre is
    generic (
        constant M: integer := 6000 -- modulo do contador
    );
    port (
        clock   : in  std_logic;
        zera_as : in  std_logic;
        zera_s  : in  std_logic;
        conta   : in  std_logic;
        Q       : out std_logic_vector(natural(ceil(log2(real(M))))-1 downto 0);
        fim     : out std_logic;
        meio    : out std_logic;
        rodada  : in  std_logic_vector(3 downto 0)
    );
end entity contador_m_decre;

architecture comportamental of contador_m_decre is
    signal IQ: integer range 0 to M-1;
    signal tempoInicial: integer range 0 to M-1;
    signal tempoIntermed : std_logic_vector(10 downto 0);
begin

    tempoInicial <= to_integer(unsigned(tempoIntermed));

    process(clock,zera_as,zera_s,conta,IQ)
    begin
        if zera_as='1' then    IQ <= tempoInicial;   
            elsif rising_edge(clock) then
            if zera_s='1' then IQ <= tempoInicial;
            elsif conta='1' then 
                if IQ=M-1 then IQ <= tempoInicial; 
                else           IQ <= IQ + 1; 
                end if;
            else               IQ <= IQ;
            end if;
        end if;
    end process;

    tempoIntermed <= "11011010110" when (rodada = "1111") or (rodada = "1110") else
                     "10111011100" when rodada = "1101" or rodada = "1100" else
                     "10011100010" when rodada = "1011" or rodada = "1010" else
                     "01111101000" when rodada = "1001" or rodada = "1000" else
                     "01011101110" when rodada = "0111" or rodada = "0110" else
                     "00111110100" when rodada = "0101" or rodada = "0100" else
                     "00011111010" when rodada = "0011" or rodada = "0010" else
                     "00000000000" when rodada = "0001" or rodada = "0000" else
                     "00000000000";


    -- saida fim
    fim <= '1' when IQ=M-1 else
           '0';

    -- saida meio
    meio <= '1' when IQ>=(M*2)/5-1 else
            '0';

    -- saida Q
    Q <= std_logic_vector(to_unsigned(IQ, Q'length));

end architecture comportamental;
