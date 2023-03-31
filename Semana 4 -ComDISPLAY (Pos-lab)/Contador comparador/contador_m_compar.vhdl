-----------------Laboratorio Digital-------------------------------------
-- Arquivo   : contador_m_compar.vhd
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
--             CONT50: contador_m_compar 
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

entity contador_m_compar is
    generic (
        constant M: integer := 2000000 -- modulo do contador
    );
    port (
        clock        : in  std_logic;
        zera_as      : in  std_logic;
        zera_s       : in  std_logic;
        conta        : in  std_logic;
        jogadorAtual : in  std_logic; -- indica qual jogador esta jogando agora
        Q            : out std_logic_vector(natural(ceil(log2(real(M))))-1 downto 0);
        fim          : out std_logic;
        meio         : out std_logic;
        jogadorRap   : out std_logic -- indica quem é o jogador mais rapido até agora (0 -> jogador 1)   (1-> jogador 2)
    );
end entity contador_m_compar;

architecture comportamental of contador_m_compar is
    signal IQ1: integer range 0 to M-1;
    signal IQ2: integer range 0 to M-1;
begin

    process (clock,zera_as,zera_s,conta,IQ1, IQ2)
    begin
        if jogadorAtual='0' then
            if zera_as='1' then    IQ1 <= 0;   
            elsif rising_edge(clock) then
                if zera_s='1' then IQ1 <= 0;
                elsif conta='1' then 
                    if IQ1=M-1 then IQ1 <= 0; 
                    else           IQ1 <= IQ1 + 1; 
                    end if;
                else               IQ1 <= IQ1;
                end if;
            end if;
        elsif jogadorAtual='1' then
            if zera_as='1' then    IQ2 <= 0;   
            elsif rising_edge(clock) then
                if zera_s='1' then IQ2 <= 0;
                elsif conta='1' then 
                    if IQ2=M-1 then IQ2 <= 0; 
                    else           IQ2 <= IQ2 + 1; 
                    end if;
                else               IQ2 <= IQ2;
                end if;
            end if;
        end if;
    end process;

    -- saida fim
    fim <= '1' when IQ1=M-1 else
           '1' when IQ2=M-1 else
           '0';

    -- saida meio
    meio <= '1' when IQ1>=(M*2)/5-1 else
            '1' when IQ2>=(M*2)/5-1 else
            '0';

    jogadorRap <= '1' when IQ1 >= IQ2 else
                  '0';
    -- saida Q
    Q <= std_logic_vector(to_unsigned(IQ1, Q'length));

end architecture comportamental;
