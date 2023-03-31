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
        
        --Modo de Jogo 3
        
        fimTimerTDecre     : in  std_logic;            --Sinal de condição: fim do timer de TimeOut
        contaTDecre        : out std_logic;                --Sinal de controle: enable do timer de TimeOut
        zeraContadorTDecre : out std_logic;           --Sinal de controle: reset do timer de TimeOut
        
        --Modo de jogo 4
        
        jogadorRap          : in  std_logic;            --Indica o jogador mais rapido até agora.
        contaTCompar        : out std_logic;           --Sinal de controle: enable do timer de TimeOut
        zeraContadorTCompar : out std_logic;           --Sinal de controle: reset do timer de TimeOut
        
        mostraOLA           : out std_logic;
        mostraSelect        : out std_logic;
        mostraNivel         : out std_logic;
        mostraUser1         : out std_logic;
        mostraVidaUser1     : out std_logic;
        mostraUser2         : out std_logic;
        mostraVidaUser2     : out std_logic;
        mostraJogadorAtual  : out std_logic;
        mostraGanhou        : out std_logic;
        mostraEmpate        : out std_logic;
        fimTransitorio      : in std_logic;                --Indica o fim do timer de Transição
        contaTransitorio    : out std_logic;                --Enable do timer de Timer de transição                
        zeraTransitorio     : out std_logic;                --Reset do timer de Timer de transição
        mostraPlacar        : out std_logic;          --Sinal de controle: permite primeira que mostre o placar
        
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

     --Modo de Jogo 3
     jogadasMultiTDecre, esperaNovaJogadaMultiTDecre,

     preparacao, iniRodada, proxRodada, ultRodada, jogadas, mostraNIvelEstado, mostraUser1Estado, mostraVidaUser1Estado,
     mostraUser2Estado, mostraVidaUser2Estado, mostraJogadorAtualEstado, mostraGanhouEstado,
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
        inicial                 when Eatual=inicial and iniciar='0' else
        seletorNivel            when Eatual=inicial and iniciar='1' else
        seletorNivel            when Eatual=seletorNivel and fezJogada = '0' else
        registraNivelEstado     when Eatual=seletorNivel and fezJogada = '1' else
        mostraNivelEstado       when Eatual=registraNivelEstado else
        mostraNIvelEstado       when Eatual=mostraNivelEstado and fimTransitorio='0' else
        preparacao              when Eatual=mostraNivelEstado and fimTransitorio='1' else
        iniRodada               when Eatual=preparacao and nivelSelecionado="0001" else
        iniRodadaMulti          when Eatual=preparacao and (nivelSelecionado="0010" or nivelSelecionado="0100") else
        mostraJogadaEstado      when Eatual=iniRodada else
        mostraPlacarJogador     when Eatual=iniRodadaMulti else
        mostraJogadaEstado      when Eatual=mostraJogadaEstado and mostrouJogada='0' else
        resetaContadorE         when Eatual=mostraJogadaEstado and mostrouJogada='1' else
        jogadas                 when Eatual=resetaContadorE and nivelSelecionado="0001" else
        jogadasMulti            when Eatual=resetaContadorE and nivelSelecionado="0010" else
        jogadasMultiTDecre      when Eatual=resetaContadorE and nivelSelecionado="0100" else
        mostraPlacarJogador     when Eatual=mostraPlacarJogador and fimTransitorio='0' else        
        mostraUser1Estado         when Eatual=mostraPlacarJogador and fimTransitorio='1' else
        mostraUser1Estado         when Eatual=mostraUser1Estado and fimTransitorio='0' else        
        mostraVidaUser1Estado     when Eatual=mostraUser1Estado and fimTransitorio='1' else
        mostraVidaUser1Estado     when Eatual=mostraVidaUser1Estado and fimTransitorio='0' else        
        mostraUser2Estado         when Eatual=mostraVidaUser1Estado and fimTransitorio='1' else
        mostraUser2Estado         when Eatual=mostraUser2Estado and fimTransitorio='0' else        
        mostraVidaUser2Estado     when Eatual=mostraUser2Estado and fimTransitorio='1' else
        mostraVidaUser2Estado     when Eatual=mostraVidaUser2Estado and fimTransitorio='0' else        
        mostraJogadorAtualEstado  when Eatual=mostraVidaUser2Estado and fimTransitorio='1' else
        mostraJogadorAtualEstado  when Eatual=mostraJogadorAtualEstado and fimTransitorio='0' else        
        mostraJogadaEstado        when Eatual=mostraJogadorAtualEstado and fimTransitorio='1' else
        -- mostraJogadaEstado     when Eatual=mostraPlacarJogador and mostrouJogada='0' else
        -- mostraJogadaEstado     when Eatual=mostraPlacarJogador and mostrouJogada='0' else   --(estranho)
        jogadasMulti            when Eatual=jogadasMulti and fezJogada='0' and fimTimer = '0' else
        erroTimeOutMulti        when Eatual=jogadasMulti and fimTimer = '1'  else  
        registraMulti           when Eatual=jogadasMulti and fezJogada='1' and fimTimer = '0' else                 
        erroTimeOutMulti        when Eatual=jogadasMultiTDecre and fimTimerTDecre = '1'  else   --Depois vai para onde?
        jogadasMultiTDecre      when Eatual=jogadasMultiTDecre and fezJogada='0' and fimTimerTDecre = '0' else
        registraMulti           when Eatual=jogadasMultiTDecre and fezJogada='1' and fimTimerTDecre = '0' else                 
        jogador1Ganha           when Eatual=jogador1Ganha and fimTransitorio='0' else             
        mostraGanhouEstado      when Eatual=jogador1Ganha and fimTransitorio='1' else  
        mostraGanhouEstado      when Eatual=mostraGanhouEstado and iniciar='0' else  
        preparacao              when Eatual=mostraGanhouEstado and iniciar='1' else  
        mostraGanhouEstado      when Eatual=mostraGanhouEstado and iniciar ='0' else  
        jogador2Ganha           when Eatual=jogador2Ganha and fimTransitorio ='0' else             
        mostraGanhouEstado      when Eatual=jogador2Ganha  and fimTransitorio='1' else  
        jogadasMulti            when Eatual=proximoMulti and nivelSelecionado="0010" else
        jogadasMultiTDecre      when Eatual=proximoMulti and nivelSelecionado="0100" else
        preparacao              when Eatual=ambosGanham and iniciar='1' else  
        ambosGanham             when Eatual=ambosGanham and iniciar ='0' else  
        comparacaoMulti         when Eatual=registraMulti else
        proximoMulti            when Eatual=comparacaoMulti and fimRodada='0' and igual = '1' else 
        ultRodadaMulti          when Eatual=comparacaoMulti and fimRodada='1' and igual = '1' else
        decrementaVida2         when Eatual=comparacaoMulti and igual='0' and rodadaAtual(0)='1' else
        decrementaVida1         when Eatual=comparacaoMulti and igual='0' and rodadaAtual(0)='0' else
        proxRodadaMulti         when Eatual=ultRodadaMulti and fimCerto='0' else
        ambosGanham             when Eatual=ultRodadaMulti and fimCerto = '1' else 
        jogador1Ganha           when Eatual=ultRodadaMulti and fimCerto = '1' and jogadorRap='0' else -- Esquema de vitória para modo 4
        jogador2Ganha           when Eatual=ultRodadaMulti and fimCerto = '1' and jogadorRap='1' else -- Esquema de vitória para o modo 4
        esperaNovaJogadaMulti   when Eatual=proxRodadaMulti and nivelSelecionado="0010" else
        esperaNovaJogadaMultiTDecre  when Eatual=proxRodadaMulti and nivelSelecionado="0100" else
        esperaNovaJogadaMulti   when Eatual=esperaNovaJogadaMulti and fezJogada='0' and fimTimer='0' else
        erroTimeOutMulti        when Eatual=esperaNovaJogadaMulti and fimTimer = '1'  else  
        registraNovaJogadaMulti when Eatual=esperaNovaJogadaMulti and fezJogada='1' and fimTimer='0' else
        escreveNovaJogadaMulti  when Eatual=registraNovaJogadaMulti else
        iniRodadaMulti          when Eatual=escreveNovaJogadaMulti else
        iniRodadaMulti          when Eatual=decrementaVida1 and fimVidaJogador1='0' else
        jogador2Ganha           when Eatual=decrementaVida1 and fimVidaJogador1='1' else
        iniRodadaMulti          when Eatual=decrementaVida2 and fimVidaJogador2='0' else             
        jogador1Ganha           when Eatual=decrementaVida2 and fimVidaJogador2='1' else                          
        jogador1Ganha           when Eatual=erroTimeOutMulti and rodadaAtual(0)='1' else       
        jogador2Ganha           when Eatual=erroTimeOutMulti and rodadaAtual(0)='0' else       
        esperaNovaJogadaMultiTDecre   when Eatual=esperaNovaJogadaMultiTDecre and fezJogada='0' and fimTimerTDecre='0' else
        erroTimeOutMulti        when Eatual=esperaNovaJogadaMultiTDecre and fimTimerTDecre = '1'  else  
        registraNovaJogadaMulti when Eatual=esperaNovaJogadaMultiTDecre and fezJogada='1' and fimTimerTDecre='0' else
        jogadas                 when  Eatual=jogadas and fezJogada='0' and fimTimer = '0' else
        erroTimeOut             when  Eatual=jogadas and fimTimer = '1'  else  
        registra                when  Eatual=jogadas and fezJogada='1' and fimTimer = '0' else                 
        erroTimeOut             when  Eatual=esperaNovaJogada and fimTimer = '1'  else  
        erroTimeOut             when  Eatual=erroTimeOut and iniciar='0' else
        preparacao              when  Eatual=erroTimeOut and iniciar='1' else  
        comparacao              when  Eatual=registra else
        proximo                 when  Eatual=comparacao and fimRodada='0' and igual = '1' else 
        ultRodada               when  Eatual=comparacao and fimRodada='1' and igual = '1' else
        errado                  when  Eatual=comparacao and igual = '0' else
        jogadas                 when  Eatual=proximo else
        preparacao              when  Eatual=errado and iniciar = '1' else
        errado                  when  Eatual=errado and iniciar='0' else        
        proxRodada              when  Eatual=ultRodada and fimCerto='0' else
        certo                   when  Eatual=ultRodada  and fimCerto = '1' else 
        preparacao              when  Eatual=certo and iniciar='1' else
        certo                   when  Eatual=certo and iniciar='0' else
        iniRodada               when  Eatual=proxRodada else                                       
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
        contaT <=     '1' when jogadas | esperaNovaJogada | jogadasMulti | esperaNovaJogadaMulti,
                      '0' when others;

    with Eatual select  
        zeraContador <= '0' when jogadas | esperaNovaJogada | jogadasMulti | esperaNovaJogadaMulti,
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

    --Modo de Jogo 3
    
    with Eatual select
        contaTDecre <='1' when jogadasMultiTDecre | esperaNovaJogadaMultiTDecre,
                      '0' when others;

    with Eatual select  
        zeraContadorTDecre <= '0' when jogadasMultiTDecre | esperaNovaJogadaMultiTDecre,
                              '1' when others;

    --Modo de Jogo 4

    with Eatual select 
        contaTCompar <= '1' when jogadasMulti | esperaNovaJogadaMulti,
                        '0' when others;
    
    with Eatual select  
        zeraContadorTCompar <= '1' when preparacao,
                               '0' when others;

    --Transitório                           
                               
    with Eatual select  
        mostraOLA <= '1' when inicial,
                     '0' when others;
                               
    with Eatual select  
        mostraSelect <= '1' when seletorNivel,
                     '0' when others;
                               
    with Eatual select  
        contaTransitorio <= '1' when mostraNivelEstado | mostraPlacarJogador | mostraGanhouEstado | mostraUser1Estado | mostraVidaUser1Estado | mostraUser2Estado | mostraVidaUser2Estado | mostraJogadorAtualEstado,
                            '0' when others;
                               
    with Eatual select  
        mostraNivel <= '1' when mostraNivelEstado,
                       '0' when others;
                                                       
    with Eatual select  
        mostraUser1 <= '1' when mostraUser1Estado | jogador1Ganha,
                       '0' when others;
                                                      
    with Eatual select  
        mostraVidaUser1 <= '1' when mostraVidaUser1Estado,
                       '0' when others;
                                                        
    with Eatual select  
        mostraUser2 <= '1' when mostraUser2Estado | jogador2Ganha,
                       '0' when others;
                                                        
    with Eatual select  
        mostraEmpate <= '1' when ambosGanham,
                        '0' when others;
                               
    with Eatual select  
        mostraVidaUser2 <= '1' when mostraVidaUser2Estado,
                       '0' when others;
                                            
    with Eatual select  
        mostraJogadorAtual <= '1' when mostraJogadorAtualEstado,
                       '0' when others;
                                            
    with Eatual select  
        mostraGanhou <= '1' when mostraGanhouEstado,
                       '0' when others;
                               
    with Eatual select  
        zeraTransitorio <= '0' when mostraNivelEstado | mostraGanhouEstado| mostraPlacarJogador | mostraUser1Estado | mostraVidaUser1Estado | mostraUser2Estado | mostraVidaUser2Estado | mostraJogadorAtualEstado,
                           '1' when others;
    
    -- saida de depuracao (db_estado)
    with Eatual select
        db_estado <= "0000" when inicial,                -- 0
                     "0001" when seletorNivel,           -- 1
                     "0010" when jogadasMulti,           -- 2
                     "0011" when esperaNovaJogadaMulti,  -- 3
                     "0100" when jogador1Ganha,          -- 4
                     "0101" when jogador2Ganha,          -- 5
                     "0110" when ambosGanham,            -- 6
                     "0111" when mostraPlacarJogador,    -- 7
                     "0100" when proxRodada,             -- 8
                     "1010" when esperaNovaJogada,       -- A
                     "1100" when certo,                  -- C    
                     "1110" when errado,                 -- E
                     "1111" when erroTimeOut,            -- E  
                     "1110" when others;                 -- F

end architecture fsm;
