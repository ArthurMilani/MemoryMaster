--------------------------------------------------------------------
-- Arquivo   : unidade_controle.vhd
-- Projeto   : Experiencia 3 - Projeto de uma unidade de controle
--------------------------------------------------------------------
-- Descricao : unidade de controle 
--
--             1) codificação VHDL (maquina de Moore)
--
--             2) definicao de valores da saida de depuracao
--                db_estado
-- 
--------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     20/01/2022  1.0     Edson Midorikawa  versao inicial
--     22/01/2023  1.1     Edson Midorikawa  revisao
--------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;

entity unidade_controle is 
    port ( 
        --Inicio do Jogo
        registraNivel :    out  std_logic;
        zeraNivel     :    out  std_logic;
        nivelSelecionado : in   std_logic_vector(3 downto 0);

        --Modo De Jogo 1
        mostrouJogada  : in  std_logic;               --Indica quando terminou mostrar as jogadas    
        zeraTimerLed   : out std_logic;               --Sinal de controle: reset do timer de Leds
        contaTimerLed  : out std_logic;               --Sinal de controle: enable do timer de Leds
        mostraJogada   : out std_logic;               --Sinal de controle: permite primeira jogada aparecer

        clock          : in  std_logic; 
        reset          : in  std_logic;               --Sinal de condição: reset do circuito
        iniciar        : in  std_logic;               --Sinal de condição: inicio do jogo
        fimCerto       : in  std_logic;               --Sinal de condição: fim certo
        fezJogada      : in  std_logic;               --Sinal de condição: indica jogada realizada
        igual          : in  std_logic;               --Sinal de condição: acertou a jogada        
        fimTimer       : in  std_logic;               --Sinal de condição: fim do timer de TimeOut
        fimRodada      : in  std_logic;               --Sinal de condição: fim da rodada atual
        zeraE          : out std_logic;               --Sinal de controle: reset do contador de jogadas
        contaE         : out std_logic;               --Sinal de controle: enable do contador de jogadas
        zeraCR         : out std_logic;               --Sinal de controle: reset do contador de rodadas
        contaCR        : out std_logic;               --Sinal de controle: enable do contador de rodadas
        zeraR          : out std_logic;               --Sinal de controle: reset do registrador
        registraR      : out std_logic;               --Sinal de controle: enable do registrador
        ganhou         : out std_logic;               --Sinal de controle: ganhou o jogo
        perdeu         : out std_logic;               --Sinal de controle: perdeu o jogo
        pronto         : out std_logic;               --Sinal de controle: fim do jogo
        contaT         : out std_logic;               --Sinal de controle: enable do timer de TimeOut
        escreve        : out std_logic;               --Sinal de controle: enable da memória
        
        db_timeout     : out std_logic;               --Sinal de deputação: Indica timeOut
        zeraContador   : out std_logic;               --Sinal de controle: reset do timer de TimeOut

        db_estado      : out std_logic_vector(3 downto 0)   --Sinal de depuração: estado atual
    );
end entity;

architecture fsm of unidade_controle is
    type t_estado is 
    --InicioDoCircuito
    (inicial, seletorNivel, registraNivelEstado,
    --Modo de Jogo 1
     mostraJogadaEstado, resetaContadorE,

     preparacao, iniRodada, proxRodada, ultRodada, jogadas,
     registra, comparacao, proximo, certo, errado, erroTimeOut, esperaNovaJogada, registraNovaJogada,
     escreveNovaJogada, contaMaisUm, jogadaAleatoria);
    signal Eatual, Eprox: t_estado;
begin

    -- memoria de estado
    process (clock,reset)
    begin
        if reset='1' then
            Eatual <= inicial;
        elsif clock'event and clock = '1' then
            Eatual <= Eprox; 
        end if;
    end process;

    -- logica de proximo estado
    Eprox <=
        --InicioDoCircuito
        inicial            when  Eatual=inicial and iniciar='0' else
        seletorNivel       when  Eatual=inicial and iniciar='1' else
        seletorNivel       when  Eatual=seletorNivel and fezJogada = '0' else
        registraNivelEstado when Eatual=seletorNivel and fezJogada = '1' else
        preparacao         when  Eatual=registraNivelEstado else
        
        --JogoModo1
        
        iniRodada          when  Eatual=preparacao and nivelSelecionado="0001" else
        mostraJogadaEstado when  Eatual=iniRodada else
        mostraJogadaEstado when  Eatual=mostraJogadaEstado and mostrouJogada='0' else
        resetaContadorE    when  Eatual=mostraJogadaEstado and mostrouJogada='1' else
        jogadas            when  Eatual=resetaContadorE else

        jogadas            when  Eatual=jogadas and fezJogada='0' and fimTimer = '0' else
        erroTimeOut        when  Eatual=jogadas and fimTimer = '1'  else  
        erroTimeOut        when  Eatual=esperaNovaJogada and fimTimer = '1'  else  
        erroTimeOut        when  Eatual=erroTimeOut and iniciar = '0' else
        preparacao         when  Eatual=erroTimeOut and iniciar='1' else  
        registra           when  Eatual=jogadas and fezJogada='1' and fimTimer = '0' else                 
        comparacao         when  Eatual=registra else
        proximo            when  Eatual=comparacao and fimRodada='0' and igual = '1' else 
        jogadas            when  Eatual=proximo else
        ultRodada          when  Eatual=comparacao and fimRodada='1' and igual = '1' else
        certo              when  Eatual=ultRodada  and fimCerto = '1' else 
        certo              when  Eatual=certo and iniciar='0' else
        preparacao         when  Eatual=certo and iniciar='1' else
        errado             when  Eatual=comparacao and igual = '0' else
        errado             when  Eatual=errado and iniciar='0' else
        preparacao         when  Eatual=errado and iniciar = '1' else
        proxRodada         when  Eatual=jogadaAleatoria else
        iniRodada          when  Eatual=proxRodada else
        jogadaAleatoria    when  Eatual=contaMaisUm else
        contaMaisUm        when  Eatual=ultRodada and fimCerto ='0' else
              
        inicial;

    -- logica de saída (maquina de Moore)

    --InicioDoCircuito
    with Eatual select
        registraNivel <= '1' when registraNivelEstado,
                         '0' when others;

    with Eatual select
        zeraNivel <= '1' when inicial,
                     '0' when others;

    --Modo de Jogo 1
    with Eatual select  
        contaTimerLed <= '1' when mostraJogadaEstado,
                         '0' when others;
    
    with Eatual select             
        zeraTimerLed <= '0' when mostraJogadaEstado,
                        '1' when others;

    with Eatual select
        mostraJogada <= '1' when mostraJogadaEstado,
                        '0' when others;

    with Eatual select
        zeraE <=      '1' when iniRodada | inicial | preparacao | resetaContadorE,                          
                      '0' when others;
    
    with Eatual select
        zeraR <=      '1' when preparacao,
                      '0' when others;
    
    with Eatual select
        registraR <=  '1' when registra,
                      '0' when others;

                      
    with Eatual select
        contaE  <=     '1' when proximo | contaMaisUm,
                      '0'  when others;

    with Eatual select
        contaCR <=   '1' when proxRodada,
                     '0' when others;

    with Eatual select
        zeraCR  <=   '1' when preparacao,
                     '0' when others;
    
    with Eatual select
        pronto <=     '1' when certo | errado | erroTimeOut,  
                      '0' when others;

    with Eatual select               
        ganhou  <=    '1' when certo,
                      '0' when others;

    with Eatual select
        perdeu <=      '1' when errado | erroTimeOut,
                      '0' when others;

    with Eatual select
        contaT <=     '1' when jogadas | esperaNovaJogada,
                      '0' when others;

    with Eatual select  
        zeraContador <= '0' when jogadas | esperaNovaJogada,
                        '1' when others;

    with Eatual select           
        db_timeOut <= '1' when erroTimeOut,
                      '0' when others;

    with Eatual select
        escreve <= '1' when jogadaAleatoria,
                   '0' when others;

    

    
    -- saida de depuracao (db_estado)
    with Eatual select
        db_estado <= "0000" when inicial,           -- 0
                     "0001" when preparacao,        -- 1
                     "0010" when iniRodada,         -- 2
                     "0011" when jogadas,           -- 3
                     "0100" when registra,          -- 4
                     "0101" when comparacao,        -- 5
                     "0110" when proximo,           -- 6
                     "0111" when ultRodada,         -- 7
                     "0100" when proxRodada,        -- 8
                     "1010" when esperaNovaJogada,  -- A
                     "1100" when certo,             -- C    
                     "1110" when errado,            -- E
                     "1110" when erroTimeOut,       -- E  
                     "1111" when others;            -- F

end architecture fsm;
