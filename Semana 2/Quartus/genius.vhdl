-------------------------------------------------------------------
-- Arquivo   : circuito_exp3.vhdl
-- Projeto   : Experiencia 3 - Projeto de Uma Unidade de Controle
-------------------------------------------------------------------
-- Descricao : conexão entre DataFlux e UC
--             Utiliza outros componentes já feitos
--             
-------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor                    Descricao
--     25/01/2023  1.0     Arthur Milani Giovanini  criacao
-------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;



entity genius is
    port (
    clock : in std_logic;
    reset : in std_logic;
    iniciar : in std_logic;
    chaves : in std_logic_vector (3 downto 0);
    pronto : out std_logic;
    ganhou : out std_logic; 
    perdeu : out std_logic; 
    leds   : out std_logic_vector(3 downto 0);

    --Sinais de depuração
    db_igual       : out std_logic;
    display1       : out std_logic_vector (6 downto 0);
    display2       : out std_logic_vector (6 downto 0);
    display3       : out std_logic_vector (6 downto 0);
    display4       : out std_logic_vector (6 downto 0);
    display5       : out std_logic_vector (6 downto 0);
    display6       : out std_logic_vector (6 downto 0);
    db_clock       : out std_logic;
    db_tem_jogada  : out std_logic;
    db_timeout     : out std_logic
    );
   end entity;
   

architecture estrutural of genius is

    component fluxo_dados is
        port (
            --Seletor de nível
            registraNivel       : in  std_logic;                --Enable do registrador de nível do jogo
            zeraNivel           : in  std_logic;                --Reset do Registrador de nível
            nivelSelecionado     : out std_logic_vector;         --Representa o nível selecionado

            --Modo de Jogo 1
            
            zeraTimerLed        : in  std_logic;                --Reset timer das Leds
            contaTimerLed       : in  std_logic;                --Enable timer das Leds
            mostraJogada        : in  std_logic;                --Enable para mostrar as jogadas a serem feitas
            mostrouJogada       : out std_logic;

            --Modo de Jogo 2

            contaVidaJogador1   : in std_logic; 
            contaVidaJogador2   : in std_logic; 
            zeraVida1           : in std_logic; 
            zeraVida2           : in std_logic;
            fimVidaJogador1     : out std_logic;      
            fimVidaJogador2     : out std_logic;
            rodadaAtual         : out std_logic_vector (3 downto 0);   --Valor da rodada (contador de rodadas) 
            vidaAtual1          : out std_logic_vector (3 downto 0);   --Valor da vida do jogador 1 (contador de vidas) 
            vidaAtual2          : out std_logic_vector (3 downto 0);   --Valor da vida do jogador 2 (contador de vidas)      

            clock               : in  std_logic;
            zeraE               : in  std_logic;                --Reset contador de jogadas     
            contaE              : in  std_logic;                --Enable contador de jogadas
            zeraR               : in  std_logic;                --Zera registrador das chaves
            registraR           : in  std_logic;                --Enable registrador das chaves 
            contaT              : in  std_logic;                --Enable do timer de TimeOut                 
            zeraT               : in  std_logic;                --Reset do timer de TimeOut
            contaCR             : in  std_logic;                --Enable contador de Rodadas           
            zeraCR              : in  std_logic;                --Reset contador de jogadas     
            chaves              : in  std_logic_vector (3 downto 0);  --Valor de entrada das chaves 
            igual               : out std_logic;                --Indica que a jogada está correta (registrador e memoria iguais)
            fimE                : out std_logic;                --Indica o fim do jogo (jogada chega no ultimo endereço)       
            pulso_de_jogada     : out std_logic;                --Pulso do EdgeDetector         
            db_tem_jogada       : out std_logic;                --Or indicando se alguma chave está on
            fimT                : out std_logic;                --Indica o fim do timer de TimeOut
            fimCR               : out std_logic;                --Indica o fim do contador de rodadas(inútil)
            fimRodada           : out std_logic;                --Indica final da rodada (contadores iguais)                  
            leds                : out std_logic_vector (3 downto 0);   --Valor de saída das leds                         
            db_contagem         : out std_logic_vector (3 downto 0);  --Valor do contador de jogadas (endereço)
            db_memoria          : out std_logic_vector (3 downto 0);  --Valor da memória
            db_jogada           : out std_logic_vector (3 downto 0);  --Valor da jogada (pós registrador)
            db_rodada           : out std_logic_vector (3 downto 0)   --Valor da rodada (contador de rodadas)
            );
    end component;

    component unidade_controle is 
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

            rodadaAtual         : in std_logic_vector (3 downto 0);   --Valor da rodada (contador de rodadas)
            fimVidaJogador1     : in std_logic;      
            fimVidaJogador2     : in std_logic;
            contaVidaJogador1   : out std_logic;          --Sinal de controle: enable do contador de vidas do jogador 1
            contaVidaJogador2   : out std_logic;          --Sinal de controle: enable do contador de vidas do jogador 2
            zeraVida1           : out std_logic;          --Sinal de controle: zera o contador de vidas do jogador 1
            zeraVida2           : out std_logic;          --Sinal de controle: zera o contador de vidas do jogador 2
            vencedor1           : out std_logic;
            vencedor2           : out std_logic;
            mostraPlacar        : out std_logic;          --Sinal de controle: permite primeira jogada aparecer
            mostraVencedor      : out std_logic;          --Sinal de controle: permite 

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
    end component;

    component hexa7seg is
        port (
            hexa : in  std_logic_vector(3 downto 0);
            sseg : out std_logic_vector(6 downto 0)
        );
    end component;

    signal s_display1            : std_logic_vector (3 downto 0);
    signal s_display2            : std_logic_vector (3 downto 0);
    signal s_display3            : std_logic_vector (3 downto 0);
    signal s_display4            : std_logic_vector (3 downto 0);
    signal s_display5            : std_logic_vector (3 downto 0);
    signal s_display6            : std_logic_vector (3 downto 0);
    signal s_contagem            : std_logic_vector (3 downto 0);
    signal s_memoria             : std_logic_vector (3 downto 0);
    signal s_chaves              : std_logic_vector (3 downto 0);
    signal s_estado              : std_logic_vector (3 downto 0);
    signal s_rodada            : std_logic_vector (3 downto 0);
    
    signal s_nivelSelecionado    : std_logic_vector (3 downto 0);
    signal s_rodadaAtual         : std_logic_vector (3 downto 0);
    signal s_vidaAtual1          : std_logic_vector (3 downto 0);
    signal s_vidaAtual2          : std_logic_vector (3 downto 0);
    
    signal s_contaVidaJogador1   : std_logic; 
    signal s_contaVidaJogador2   : std_logic; 
    signal s_zeraVida1           : std_logic; 
    signal s_zeraVida2           : std_logic;
    signal s_fimVidaJogador1     : std_logic;      
    signal s_fimVidaJogador2     : std_logic;
    signal s_vencedor1           : std_logic;
    signal s_vencedor2           : std_logic;
    signal s_contaE              : std_logic;
    signal s_fimE                : std_logic;
    signal s_zeraE               : std_logic;
    signal s_zeraR               : std_logic;
    signal s_contaR              : std_logic;
    signal s_registraR           : std_logic;
    signal s_igual               : std_logic;   
    signal s_pulso_de_jogada     : std_logic;
    signal s_zeraT               : std_logic;
    signal s_contaT              : std_logic;
    signal s_escreve             : std_logic;
    signal s_fimT                : std_logic;
    signal s_zeraCR              : std_logic;
    signal s_contaCR             : std_logic;
    signal s_fimRodada           : std_logic;
    signal s_zeraTimerLed        : std_logic;
    signal s_contaTimerLed       : std_logic;
    signal s_mostraJogada        : std_logic;
    signal s_registraNivel       : std_logic;
    signal s_zeraNivel           : std_logic;
    signal s_mostrouJogada       : std_logic;
    signal s_mostraPlacar        : std_logic;
    signal s_mostraVencedor      : std_logic;
    

    begin

    s_display1 <= "0001" when s_mostraPlacar='1' else 
                  "0000" when s_mostraVencedor='1' else
                  s_contagem;
    
    hexa7seg_display1: hexa7seg
        port map(
            hexa => s_display1,
            sseg => display1
        );
    
    s_display2 <= "0011" when s_vidaAtual1="0000" and s_mostraPlacar='1' else
                  "0010" when s_vidaAtual1="0001" and s_mostraPlacar='1' else
                  "0001" when s_vidaAtual1="0010" and s_mostraPlacar='1' else
                  "0000" when s_mostraVencedor='1' else     
                  s_memoria;

    hexa7seg_display2: hexa7seg
        port map(
            hexa => s_display2,
            sseg => display2
        );

    s_display3 <= "0010" when s_mostraPlacar='1' else 
                  ("000" & s_vencedor1) when s_mostraVencedor='1' else
                  s_chaves;

    hexa7seg_display3: hexa7seg
        port map(
            hexa => s_display3,
            sseg => display3    
    );

    s_display4 <= "0011" when s_vidaAtual2="0000" and s_mostraPlacar='1' else
                  "0010" when s_vidaAtual2="0000" and s_mostraPlacar='1' else
                  "0001" when s_vidaAtual2="0000" and s_mostraPlacar='1' else 
                  ("000" & s_vencedor2) when s_mostraVencedor='1' else
                  s_estado;

    hexa7seg_display4: hexa7seg
        port map(
            hexa => s_display4,
            sseg => display4
        );

    s_display5 <= "0000" when s_mostraPlacar='1' else
                  "0000" when s_mostraVencedor='1' else
                  s_rodada;

    hexa7seg_display5: hexa7seg
        port map(
            hexa => s_display5,
            sseg => display5
        );
        
    s_display6 <=   ("000" & s_rodadaAtual(0)) when s_mostraPlacar='1' else
                    "0000" when s_mostraVencedor='1' else
                    "0000";

    hexa7seg_display6: hexa7seg
        port map(
            hexa => s_display6,
            sseg => display6
        );

    dataFlux : fluxo_dados        --Fluxo de Dados
        port map(
            --Seletor de Niveis
            nivelSelecionado => s_nivelSelecionado,
            registraNivel    => s_registraNivel,
            zeraNivel        => s_zeraNivel,
            
            --Modo de Jogo 1
            mostrouJogada      => s_mostrouJogada,
            zeraTimerLed       => s_zeraTimerLed,
            contaTimerLed      => s_contaTimerLed,
            mostraJogada       => s_mostraJogada,

            --Modo De Jogo 2
            rodadaAtual        => s_rodadaAtual,         
            contaVidaJogador1  => s_contaVidaJogador1,  
            contaVidaJogador2  => s_contaVidaJogador2, 
            zeraVida1          => s_zeraVida1,          
            zeraVida2          => s_zeraVida2,          
            fimVidaJogador1    => s_fimVidaJogador1,    
            fimVidaJogador2    => s_fimVidaJogador2,
            vidaAtual1         => s_vidaAtual1,  
            vidaAtual2         => s_vidaAtual2,    

            clock              => clock,
            zeraE              => s_zeraE,
            contaE             => s_contaE,
            zeraR              => s_zeraR,
            registraR          => s_registraR,
            contaCR            => s_contaCR,
            zeraCR             => s_zeraCR,
            chaves             => chaves,  
            igual              => s_igual,  
            fimE               => s_fimE,
            
            fimCR              => open,  --Não uso, só apenas o fimE
            fimRodada          => s_fimRodada,
            pulso_de_jogada    => s_pulso_de_jogada,   
            db_tem_jogada      => db_tem_jogada,
            leds               => leds,
            db_contagem        => s_contagem,
            db_memoria         => s_memoria,
            db_jogada          => s_chaves,
            db_rodada          => s_rodada,
            contaT             => s_contaT,
            zeraT              => s_zeraT,
            fimT               => s_fimT

        );

    unityControl : unidade_controle --Unidade de Controle
        port map(
            --Inicio do Jogo
            nivelSelecionado => s_nivelSelecionado,
            registraNivel    => s_registraNivel,
            zeraNivel        => s_zeraNivel,

            --Modo de Jogo 1
            zeraTimerLed  => s_zeraTimerLed,
            contaTimerLed => s_contaTimerLed,
            mostrouJogada => s_mostrouJogada,
            mostraJogada  => s_mostraJogada,
    
            --Modo De Jogo 2
            rodadaAtual       => s_rodadaAtual, 
            contaVidaJogador1 => s_contaVidaJogador1, 
            contaVidaJogador2 => s_contaVidaJogador2, 
            zeraVida1         => s_zeraVida1, 
            zeraVida2         => s_zeraVida2, 
            fimVidaJogador1   => s_fimVidaJogador1, 
            fimVidaJogador2   => s_fimVidaJogador2,     
            vencedor1         => s_vencedor1,     
            vencedor2         => s_vencedor2,     
            mostraPlacar      => s_mostraPlacar,     
            mostraVencedor    => s_mostraVencedor,     

            clock     => clock,
            reset     => reset,
            iniciar   => iniciar, 
            fimCerto  => s_fimE,
            fezJogada => s_pulso_de_jogada,    
            igual     => s_igual, 
            zeraE     => s_zeraE,
            contaE    => s_contaE,
            zeraR     => s_zeraR,
            registraR => s_registraR,
            pronto    => pronto,
            db_estado => s_estado,
            ganhou    => ganhou,  
            perdeu     => perdeu,
            fimTimer  => s_fimT,
            contaT    => s_contaT,
            escreve    => s_escreve,
            zeraContador => s_zeraT,
            db_timeout => db_timeout,
            fimRodada  => s_fimRodada,
            zeraCR     => s_zeraCR,
            contaCR    => s_contaCR
        );

    db_igual   <= s_igual;         
    db_clock   <= clock;

end architecture;