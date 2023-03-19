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
        
        --Modo De Jogo 2

        rodadaAtual         : in std_logic_vector (3 downto 0);   --Valor da Rodada, para alternar entre os jogadores
        fimVidaJogador1     : in std_logic;           --É ativado quando o jogador 1 "perde as 3 vidas", contador = 3
        fimVidaJogador2     : in std_logic;           --É ativado quando o jogador 2 "perde as 3 vidas", contador = 3
        contaVidaJogador1   : out std_logic;          --Sinal de controle: enable do contador de vidas do jogador 1
        contaVidaJogador2   : out std_logic;          --Sinal de controle: enable do contador de vidas do jogador 2
        zeraVida1           : out std_logic;          --Sinal de controle: zera o contador de vidas do jogador 1
        zeraVida2           : out std_logic;          --Sinal de controle: zera o contador de vidas do jogador 2
        vencedor1           : out std_logic;          --Sinal de controle: ativa quando o jogador 1 um ganha
        vencedor2           : out std_logic;          --Sinal de controle: ativa quando o jogador 2 um ganha
        mostraPlacar        : out std_logic;          --Sinal de controle: permite primeira que mostre o placar
        mostraVencedor      : out std_logic;          --Sinal de controle: permite primeira que mostre o vecedor(s)

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

     --Modo de Jogo 2
     iniRodadaMulti, mostraPlacarJogador, jogadasMulti, erroTimeOutMulti, registraMulti, comparacaoMulti, proximoMulti,
     ultRodadaMulti, proxRodadaMulti, registraNovaJogadaMulti, mostraGanhador, esperaNovaJogadaMulti, escreveNovaJogadaMulti,
     ambosGanham, decrementaVida1, decrementaVida2, jogador1Ganha, jogador2Ganha,

     preparacao, iniRodada, proxRodada, ultRodada, jogadas,
     registra, comparacao, proximo, certo, errado, erroTimeOut, esperaNovaJogada, registraNovaJogada,
     escreveNovaJogada);
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
        inicial              when  Eatual=inicial and iniciar='0' else
        seletorNivel         when  Eatual=inicial and iniciar='1' else
        seletorNivel         when  Eatual=seletorNivel and fezJogada = '0' else
        registraNivelEstado  when Eatual=seletorNivel and fezJogada = '1' else
        preparacao           when  Eatual=registraNivelEstado else
        
        --JogoModo1
        
        iniRodada          when  Eatual=preparacao and nivelSelecionado="0001" else
        mostraJogadaEstado when  Eatual=iniRodada else
        mostraJogadaEstado when  Eatual=mostraJogadaEstado and mostrouJogada='0' else
        resetaContadorE    when  Eatual=mostraJogadaEstado and mostrouJogada='1' else
        jogadas            when  Eatual=resetaContadorE else

        --JogoModo 2

        iniRodadaMulti          when Eatual=preparacao and nivelSelecionado="0010" else
        mostraPlacarJogador     when Eatual=iniRodadaMulti else
        mostraPlacarJogador     when Eatual=mostraPLacarJogador and fimTimer='0' else
        jogadasMulti            when Eatual=mostraPLacarJogador and fimTimer='1' else
        jogadasMulti            when Eatual=jogadasMulti and fezJogada='0' and fimTimer = '0' else
        erroTimeOutMulti        when Eatual=jogadasMulti and fimTimer = '1'  else  
        erroTimeOutMulti        when Eatual=esperaNovaJogadaMulti and fimTimer = '1'  else  
        preparacao              when Eatual=jogador1Ganha  and iniciar='1' else  
        preparacao              when Eatual=jogador2Ganha  and iniciar='1' else  
        preparacao              when Eatual=ambosGanham and iniciar='1' else  
        registraMulti           when Eatual=jogadasMulti and fezJogada='1' and fimTimer = '0' else                 
        comparacaoMulti         when Eatual=registraMulti else
        proximoMulti            when Eatual=comparacaoMulti and fimRodada='0' and igual = '1' else 
        jogadasMulti            when Eatual=proximoMulti else
        ultRodadaMulti          when Eatual=comparacaoMulti and fimRodada='1' and igual = '1' else
        proxRodadaMulti         when Eatual=ultRodadaMulti and fimCerto='0' else
        esperaNovaJogadaMulti   when Eatual=proxRodadaMulti else
        esperaNovaJogadaMulti   when Eatual=esperaNovaJogadaMulti and fezJogada='0' and fimTimer='0' else
        registraNovaJogadaMulti when Eatual=esperaNovaJogadaMulti and fezJogada='1' and fimTimer='0' else
        escreveNovaJogadaMulti  when Eatual=registraNovaJogadaMulti else
        iniRodadaMulti          when Eatual=escreveNovaJogadaMulti else
        decrementaVida1         when Eatual=comparacaoMulti and igual='0' and rodadaAtual(0)='0' else
        decrementaVida2         when Eatual=comparacaoMulti and igual='0' and rodadaAtual(0)='1' else
        iniRodadaMulti          when Eatual=decrementaVida1 and fimVidaJogador1='0' else
        iniRodadaMulti          when Eatual=decrementaVida2 and fimVidaJogador2='0' else
        jogador1Ganha           when Eatual=decrementaVida2 and fimVidaJogador2='1' else             
        jogador2Ganha           when Eatual=decrementaVida1 and fimVidaJogador1='1' else
        jogador1Ganha           when Eatual=decrementaVida2 and fimVidaJogador2='1' else             
        jogador2Ganha           when Eatual=decrementaVida1 and fimVidaJogador1='1' else             
        jogador1Ganha           when Eatual=jogador1Ganha and iniciar ='0' else             
        jogador1Ganha           when Eatual=erroTimeOutMulti and rodadaAtual(0)='1' else       
        ambosGanham             when Eatual=ultRodadaMulti and fimCerto = '1' else 
        ambosGanham             when Eatual=ambosGanham and iniciar ='0' else  
        jogador2Ganha           when Eatual=jogador2Ganha and iniciar ='0' else             
        jogador2Ganha           when Eatual=erroTimeOutMulti and rodadaAtual(0)='0' else       

        jogadas            when  Eatual=jogadas and fezJogada='0' and fimTimer = '0' else
        erroTimeOut        when  Eatual=jogadas and fimTimer = '1'  else  
        erroTimeOut        when  Eatual=esperaNovaJogada and fimTimer = '1'  else  
        erroTimeOut        when  Eatual=erroTimeOut and iniciar='0' else
        preparacao         when  Eatual=erroTimeOut and iniciar='1' else  
        registra           when  Eatual=jogadas and fezJogada='1' and fimTimer = '0' else                 
        comparacao         when  Eatual=registra else
        proximo            when  Eatual=comparacao and fimRodada='0' and igual = '1' else 
        jogadas            when  Eatual=proximo else
        ultRodada          when  Eatual=comparacao and fimRodada='1' and igual = '1' else
        errado             when  Eatual=comparacao and igual = '0' else
        preparacao         when  Eatual=errado and iniciar = '1' else
        proxRodada         when  Eatual=ultRodada and fimCerto='0' else
        certo              when  Eatual=ultRodada  and fimCerto = '1' else 
        preparacao         when  Eatual=certo and iniciar='1' else
        certo              when  Eatual=certo and iniciar='0' else
        errado             when  Eatual=errado and iniciar='0' else        
        iniRodada          when  Eatual=proxRodada else                                       
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
        zeraE <=      '1' when iniRodada | inicial | preparacao | resetaContadorE | iniRodadaMulti,                       
                      '0' when others;
    
    with Eatual select
        zeraR <=      '1' when preparacao,
                      '0' when others;
    
    with Eatual select
        registraR <=  '1' when registra | registraMulti | registraNovaJogadaMulti,
                      '0' when others;

                      
    with Eatual select
        contaE  <=     '1' when proximo | proximoMulti | proxRodadaMulti,
                       '0'  when others;

    with Eatual select
        contaCR <=   '1' when proxRodada | proxRodadaMulti,
                     '0' when others;

    with Eatual select
        zeraCR  <=   '1' when preparacao,
                     '0' when others;
    
    with Eatual select
        pronto <=     '1' when certo | errado | erroTimeOut | erroTimeOutMulti | jogador1Ganha | jogador2Ganha | ambosGanham,  
                      '0' when others;

    with Eatual select               
        ganhou  <=    '1' when certo,
                      '0' when others;

    with Eatual select
        perdeu <=      '1' when errado | erroTimeOut | erroTimeOutMulti,
                       '0' when others;

    with Eatual select
        contaT <=     '1' when jogadas | esperaNovaJogada | jogadasMulti | esperaNovaJogadaMulti | mostraPlacarJogador,
                      '0' when others;

    with Eatual select  
        zeraContador <= '0' when jogadas | esperaNovaJogada | jogadasMulti | esperaNovaJogadaMulti | mostraPlacarJogador,
                        '1' when others;

    with Eatual select           
        db_timeOut <= '1' when erroTimeOut | erroTimeOutMulti,
                      '0' when others;
                      
    -- Modo jogo 2
              
    with Eatual select
        mostraPlacar <= '1' when mostraPlacarJogador,
                        '0' when others;
    
    with Eatual select
        escreve <= '1' when escreveNovaJogadaMulti,
                   '0' when others;

    with Eatual select
        vencedor1 <= '1' when jogador1Ganha | ambosGanham,
                     '0' when others;

    with Eatual select
        vencedor2 <= '1' when jogador2Ganha | ambosGanham,
                     '0' when others;

    with Eatual select
        zeraVida1 <= '1' when preparacao,
                     '0' when others;

    with Eatual select
        zeraVida2 <= '1' when preparacao,
                     '0' when others;

    with Eatual select
        contaVidaJogador1 <= '1' when decrementaVida1,
                             '0' when others;

    with Eatual select
        contaVidaJogador2 <= '1' when decrementaVida2,
                             '0' when others;

    with Eatual select
    mostraVencedor <= '1' when jogador1Ganha | jogador2Ganha | ambosGanham,  
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
