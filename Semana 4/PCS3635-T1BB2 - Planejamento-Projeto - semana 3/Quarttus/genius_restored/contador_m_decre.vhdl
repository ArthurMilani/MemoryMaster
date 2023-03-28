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
    signal IQpartida : integer range 0 to M-1; 
begin

    process (clock,zera_as,zera_s,conta,IQ)
    begin
        if rodada="0000" then 
            if zera_as='1' then    IQ <= 0;   
            elsif rising_edge(clock) then
                if zera_s='1' then IQ <= 0;
                elsif conta='1' then 
                    if IQ=M-1 then IQ <= 0; 
                    else           IQ <= IQ + 1; 
                    end if;
                else               IQ <= IQ;
                end if;
            end if;
        elsif rodada="0001" then 
            if zera_as='1' then    IQ <= 0;   
            elsif rising_edge(clock) then
                if zera_s='1' then IQ <= 0;
                elsif conta='1' then 
                    if IQ=M-1 then IQ <= 0; 
                    else           IQ <= IQ + 1; 
                    end if;
                else               IQ <= IQ;
                end if;
            end if;
        elsif rodada="0010" then 
            if zera_as='1' then    IQ <= 250;   
            elsif rising_edge(clock) then
                if zera_s='1' then IQ <= 250;
                elsif conta='1' then 
                    if IQ=M-1 then IQ <= 250; 
                    else           IQ <= IQ + 1; 
                    end if;
                else               IQ <= IQ;
                end if;
            end if;
        elsif rodada="0011" then 
            if zera_as='1' then    IQ <= 250;   
            elsif rising_edge(clock) then
                if zera_s='1' then IQ <= 250;
                elsif conta='1' then 
                    if IQ=M-1 then IQ <= 250; 
                    else           IQ <= IQ + 1; 
                    end if;
                else               IQ <= IQ;
                end if;
            end if;
        elsif rodada="0100" then 
            if zera_as='1' then    IQ <= 500;   
            elsif rising_edge(clock) then
                if zera_s='1' then IQ <= 500;
                elsif conta='1' then 
                    if IQ=M-1 then IQ <= 500; 
                    else           IQ <= IQ + 1; 
                    end if;
                else               IQ <= IQ;
                end if;
            end if;
        elsif rodada="0101" then 
            if zera_as='1' then    IQ <= 500;   
            elsif rising_edge(clock) then
                if zera_s='1' then IQ <= 500;
                elsif conta='1' then 
                    if IQ=M-1 then IQ <= 500; 
                    else           IQ <= IQ + 1; 
                    end if;
                else               IQ <= IQ;
                end if;
            end if;
        elsif rodada="0110" then 
            if zera_as='1' then    IQ <= 750;   
            elsif rising_edge(clock) then
                if zera_s='1' then IQ <= 750;
                elsif conta='1' then 
                    if IQ=M-1 then IQ <= 750; 
                    else           IQ <= IQ + 1; 
                    end if;
                else               IQ <= IQ;
                end if;
            end if;
        elsif rodada="0111" then 
            if zera_as='1' then    IQ <= 750;   
            elsif rising_edge(clock) then
                if zera_s='1' then IQ <= 750;
                elsif conta='1' then 
                    if IQ=M-1 then IQ <= 750; 
                    else           IQ <= IQ + 1; 
                    end if;
                else               IQ <= IQ;
                end if;
            end if;
        elsif rodada="1000" then 
            if zera_as='1' then    IQ <= 1000;   
            elsif rising_edge(clock) then
                if zera_s='1' then IQ <= 1000;
                elsif conta='1' then 
                    if IQ=M-1 then IQ <= 1000; 
                    else           IQ <= IQ + 1; 
                    end if;
                else               IQ <= IQ;
                end if;
            end if;
        elsif rodada="1001" then 
            if zera_as='1' then    IQ <= 1000;   
            elsif rising_edge(clock) then
                if zera_s='1' then IQ <= 1000;
                elsif conta='1' then 
                    if IQ=M-1 then IQ <= 1000; 
                    else           IQ <= IQ + 1; 
                    end if;
                else               IQ <= IQ;
                end if;
            end if;
        elsif rodada="1010" then 
            if zera_as='1' then    IQ <= 1250;   
            elsif rising_edge(clock) then
                if zera_s='1' then IQ <= 1250;
                elsif conta='1' then 
                    if IQ=M-1 then IQ <= 1250; 
                    else           IQ <= IQ + 1; 
                    end if;
                else               IQ <= IQ;
                end if;
            end if;
        elsif rodada="1011" then 
            if zera_as='1' then    IQ <= 1250;   
            elsif rising_edge(clock) then
                if zera_s='1' then IQ <= 1250;
                elsif conta='1' then 
                    if IQ=M-1 then IQ <= 1250; 
                    else           IQ <= IQ + 1; 
                    end if;
                else               IQ <= IQ;
                end if;
            end if;
        elsif rodada="1100" then 
            if zera_as='1' then    IQ <= 1500;   
            elsif rising_edge(clock) then
                if zera_s='1' then IQ <= 1500;
                elsif conta='1' then 
                    if IQ=M-1 then IQ <= 1500; 
                    else           IQ <= IQ + 1; 
                    end if;
                else               IQ <= IQ;
                end if;
            end if;
        elsif rodada="1101" then 
            if zera_as='1' then    IQ <= 1500;   
            elsif rising_edge(clock) then
                if zera_s='1' then IQ <= 1500;
                elsif conta='1' then 
                    if IQ=M-1 then IQ <= 1500; 
                    else           IQ <= IQ + 1; 
                    end if;
                else               IQ <= IQ;
                end if;
            end if; 
        elsif rodada="1110" then 
            if zera_as='1' then    IQ <= 1750;   
            elsif rising_edge(clock) then
                if zera_s='1' then IQ <= 1750;
                elsif conta='1' then 
                    if IQ=M-1 then IQ <= 1750; 
                    else           IQ <= IQ + 1; 
                    end if;
                else               IQ <= IQ;
                end if;
            end if;
        elsif rodada="1111" then 
            if zera_as='1' then    IQ <= 1750;   
            elsif rising_edge(clock) then
                if zera_s='1' then IQ <= 1750;
                elsif conta='1' then 
                    if IQ=M-1 then IQ <= 1750; 
                    else           IQ <= IQ + 1; 
                    end if;
                else               IQ <= IQ;
                end if;
            end if;
        end if;
    end process;

    -- saida fim
    fim <= '1' when IQ=M-1 else
           '0';

    -- saida meio
    meio <= '1' when IQ>=(M*2)/5-1 else
            '0';

    -- saida Q
    Q <= std_logic_vector(to_unsigned(IQ, Q'length));

end architecture comportamental;
