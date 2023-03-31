--------------------------------------------------------------------
-- Arquivo   : circuito_exp2_ativ2.vhd.parcial.txt
-- Projeto   : Experiencia 2 - Um Fluxo de Dados Simples
--------------------------------------------------------------------
-- Descricao : ARQUIVO PARCIAL DO
--    Circuito do fluxo de dados da Atividade 2
--
-- COMPLETAR TRECHOS DE CODIGO ABAIXO
--
--    1) contem saidas de depuracao db_contagem e db_memoria
--    2) escolha da arquitetura do componente ram_16x4
--       para simulacao com ModelSim => ram_modelsim
--    3) escolha da arquitetura do componente ram_16x4
--       para sintese com Intel Quartus => ram_mif
--
--------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     11/01/2022  1.0     Edson Midorikawa  versao inicial
--     07/01/2023  1.1     Edson Midorikawa  revisao
--     10/02/2023  1.1.1   Edson Midorikawa  arquivo parcial
--     25/01/2023  1.1.2   Arthur            FLuxoDeDados
--     04/02/2023  1.1.2   Arthur            FluxoDeDados+EdgeDetector
--     21/02/2023  1.2     Arthur            Fluxo de Dados do Genius
--------------------------------------------------------------------
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity fluxo_dados is
    port (
        --Seletor de nível
        registraNivel       : in  std_logic;                --Enable do registrador de nível do jogo
        zeraNivel           : in  std_logic;                --Reset do Registrador de nível
        nivelSelecionado     : out std_logic_vector;         --Representa o nível selecionado
        escreveAleatorio     : in  std_logic;                --Seleciona o sinal aleatorio para ser escrito

        --Modo de Jogo 1
        
        zeraTimerLed        : in  std_logic;                --Reset timer das Leds
        contaTimerLed       : in  std_logic;                --Enable timer das Leds
        mostraJogada        : in  std_logic;                --Enable para mostrar as jogadas a serem feitas
        mostrouJogada       : out std_logic;

        --Modo de Jogo 2 
        
        contaVidaJogador1   : in std_logic;                        --Sinal para ativar contagem da vida do jogador 1 
        contaVidaJogador2   : in std_logic;                        --Sinal para ativar contagem da vida do jogador 2
        zeraVida1           : in std_logic;                        --Sinal para zerar a vida do jogador 1 
        zeraVida2           : in std_logic;                        --Sinal para zerar a vida do jogador 2
        fimVidaJogador1     : out std_logic;                       --Sinal para avisar que o jogador 1 perdeu todas as 3 vidas 
        fimVidaJogador2     : out std_logic;                       --Sinal para avisar que o jogador 2 perdeu todas as 3 vidas
        vidaAtual1          : out std_logic_vector (3 downto 0);   --Valor atual da vida do jogador 1 (contador de vidas) 
        vidaAtual2          : out std_logic_vector (3 downto 0);   --Valor atual da vida do jogador 2 (contador de vidas) 
        rodadaAtual         : out std_logic_vector (3 downto 0);   --Valor da rodada (contador de rodadas) 
      
        --Mode de jogo 3

        contaTDecre         : in  std_logic;                --Enable do timer de TimeOut decrescente                
        zeraTDecre          : in  std_logic;                --Reset do timer de TimeOut decrescente
        fimTDecre           : out std_logic;                --Indica o fim do timer de TimeOut decrescente
        
        --Modo de jogo 4
        
        contaTCompar         : in  std_logic;                --Enable do timer de TimeOut decrescente                
        zeraTCompar          : in  std_logic;                --Reset do timer de TimeOut decrescente
        jogadorRap          : out std_logic;                --Indica o jogador mais rapido até agora.
        
        fimTransitorio      : out std_logic;                --Indica o fim do timer de Transição
        contaTransitorio    : in  std_logic;                --Enable do timer de Timer de transição                
        zeraTransitorio     : in  std_logic;                --Reset do timer de Timer de transição
        
        clock               : in  std_logic;
        zeraE               : in  std_logic;                --Reset contador de jogadas     
        contaE              : in  std_logic;                --Enable contador de jogadas
        zeraR               : in  std_logic;                --Zera registrador das chaves
        registraR           : in  std_logic;                --Enable registrador das chaves 
        contaCR             : in  std_logic;                --Enable contador de Rodadas           
        zeraCR              : in  std_logic;                --Reset contador de jogadas     
        contaT              : in  std_logic;                --Enable do timer de TimeOut decrescente                
        zeraT               : in  std_logic;                --Reset do timer de TimeOut decrescente
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
        db_rodada           : out std_logic_vector (3 downto 0);   --Valor da rodada (contador de rodadas)
        escreve             : in std_logic
    );
end entity fluxo_dados;

architecture estrutural of fluxo_dados is

  signal s_endereco         : std_logic_vector (3 downto 0);  --Sinal intermediário: endereço atual
  signal s_memoria          : std_logic_vector (3 downto 0);  --Sinal interemdiario: valor da memória
  signal s_chaves           : std_logic_vector (3 downto 0);  --Sinal intermediário: valor das chaves (pós registrador)
  signal s_rodada           : std_logic_vector (3 downto 0);  --Sinal intermediário: valor da rodada atual
  signal s_vidaJogador1     : std_logic_vector (3 downto 0);  --Sinal intermediário: valor da vida do jogador 1
  signal s_vidaJogador2     : std_logic_vector (3 downto 0);  --Sinal intermediário: valor da vida do jogador 2
  signal s_not_zeraE        : std_logic;     --Sinal auxiliar: zera é ativo baixo
  signal s_not_zeraCR       : std_logic;     --Sinal auxiliar: zera é ativo baixo 
  signal s_not_escreve      : std_logic;     --Sinal auxiliar: escreve é ativo baixo
  signal s_not_zeraVida1    : std_logic;     --Sinal auxiliar: escreve é ativo baixo
  signal s_not_zeraVida2    : std_logic;     --Sinal auxiliar: escreve é ativo baixo
  signal orChaves           : std_logic;     --Sinal auxiliar: indica  "or" entre as chaves
  signal notOrChaves        : std_logic;     --Sinal auxiliar: indica a "nor" entre as chaves
  signal s_fimRodada        : std_logic;
  signal s_contaE           : std_logic;
  signal s_mostrouUmaJogada : std_logic;
  signal s_meioDaJogada     : std_logic;
  signal s_escreve_not      : std_logic;
  signal valorAleatorio     : std_logic_vector(3 downto 0);
  signal valorEscrito       : std_logic_vector(3 downto 0);

  component contador_163 is
    port (
        clock : in  std_logic;
        clr   : in  std_logic;
        ld    : in  std_logic;
        ent   : in  std_logic;
        enp   : in  std_logic;
        D     : in  std_logic_vector (3 downto 0);
        Q     : out std_logic_vector (3 downto 0);
        rco   : out std_logic 
    );
  end component;

  component comparador_85 is
    port (
        i_A3   : in  std_logic;
        i_B3   : in  std_logic;
        i_A2   : in  std_logic;
        i_B2   : in  std_logic;
        i_A1   : in  std_logic;
        i_B1   : in  std_logic;
        i_A0   : in  std_logic;
        i_B0   : in  std_logic;
        i_AGTB : in  std_logic;
        i_ALTB : in  std_logic;
        i_AEQB : in  std_logic;
        o_AGTB : out std_logic;
        o_ALTB : out std_logic;
        o_AEQB : out std_logic
    );
  end component;

  component ram_16x4 is   --Aqui foi escrita a entidade da ram
    port (
        clk          : in  std_logic;
        endereco     : in  std_logic_vector(3 downto 0);
        dado_entrada : in  std_logic_vector(3 downto 0);
        we           : in  std_logic;
        ce           : in  std_logic;
        dado_saida   : out std_logic_vector(3 downto 0)
    );
  end component;

  component registrador_n is
    generic (
        constant N: integer := 4 
    );
    port (
        clock  : in  std_logic;
        clear  : in  std_logic;
        enable : in  std_logic;
        D      : in  std_logic_vector (N - 1 downto 0);
        Q      : out std_logic_vector (N - 1 downto 0) 
    );
  end component;

  component edge_detector is
    port (
        clock  : in  std_logic;
        reset  : in  std_logic;
        sinal  : in  std_logic;
        pulso  : out std_logic
    );
  end component;

  component contador_m is
    generic (
        constant M: integer := 5000 -- modulo do contador
    );
    port (
        clock   : in  std_logic;
        zera_as : in  std_logic;
        zera_s  : in  std_logic;
        conta   : in  std_logic;
        Q       : out std_logic_vector(natural(ceil(log2(real(M))))-1 downto 0);
        fim     : out std_logic;
        meio    : out std_logic
    );
    end component;
  
  component contador_m_decre is
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
    end component;
  component contador_m_compar is
    generic (
        constant M: integer := 2000000 -- modulo do contador
    );
    port (
        clock        : in  std_logic;
        zera_as      : in  std_logic;
        zera_s       : in  std_logic;
        conta        : in  std_logic;
        jogadorAtual : in  std_logic;
        Q            : out std_logic_vector(natural(ceil(log2(real(M))))-1 downto 0);
        fim          : out std_logic;
        meio         : out std_logic;
        jogadorRap   : out  std_logic
    );
    end component;

    component bitvector_generator is
      port (
          clk    : in  std_logic;
          rst    : in  std_logic;
          output : out std_logic_vector(3 downto 0)
      );
    end component;

begin

  -- sinais de controle ativos em alto
  -- sinais dos componentes ativos em baixo
  s_not_zeraE      <= not zeraE;
  s_not_zeraCR     <= not zeraCR;
  s_not_zeraVida1  <= not zeraVida1;
  s_not_zeraVida2  <= not zeraVida2;
  s_contaE         <= s_mostrouUmaJogada or contaE;
  s_escreve_not    <= not escreve;

  --or das chaves de entrada
  orChaves    <= chaves(3) or chaves(2) or chaves(1) or chaves(0);
  notOrChaves <= not orChaves;

  randomGenerator: bitvector_generator
    port map (
        clk => clock,
        rst => '0',
        output => valorAleatorio
    );
  
  contadorEndereco: contador_163
    port map (
        clock => clock,  
        clr   => s_not_zeraE,  
        ld    => '1',
        ent   => '1',   
        enp   => s_contaE,
        D     => "0000",
        Q     => s_endereco,
        rco   => fimE 
    );

  contadorRodada: contador_163
    port map (
      clock => clock,
      clr   => s_not_zeraCR,
      ld    => '1',
      ent   => '1',
      enp   => contaCR,
      D     => "0000",
      Q     => s_rodada,
      rco   => fimCR
    );

  contadorVida1: contador_163
    port map (
      clock => clock,
      clr   => s_not_zeraVida1,
      ld    => '1',
      ent   => '1',
      enp   => contaVidaJogador1,
      D     => "0000",
      Q     => s_vidaJogador1,
      rco   => open
    );
  
  contadorVida2: contador_163
    port map (
      clock => clock,
      clr   => s_not_zeraVida2,
      ld    => '1',
      ent   => '1',
      enp   => contaVidaJogador2,
      D     => "0000",
      Q     => s_vidaJogador2,
      rco   => open
    );

  ComparadorJogada: comparador_85
    port map (
        i_A3   => s_memoria(3),
        i_B3   => s_chaves(3),
        i_A2   => s_memoria(2),   
        i_B2   => s_chaves(2),
        i_A1   => s_memoria(1),   
        i_B1   => s_chaves(1),
        i_A0   => s_memoria(0),  
        i_B0   => s_chaves(0),
        i_AGTB => '0',
        i_ALTB => '0',
        i_AEQB => '1',
        o_AGTB => open, -- saidas nao usadas
        o_ALTB => open,
        o_AEQB => igual                
    );

  ComparadorEndereco: comparador_85
    port map (
        i_A3   => s_rodada(3),
        i_B3   => s_endereco(3),
        i_A2   => s_rodada(2),   
        i_B2   => s_endereco(2),
        i_A1   => s_rodada(1),   
        i_B1   => s_endereco(1),
        i_A0   => s_rodada(0),
        i_B0   => s_endereco(0),
        i_AGTB => '0',
        i_ALTB => '0',
        i_AEQB => '1',
        o_AGTB => open, -- saidas nao usadas
        o_ALTB => open,
        o_AEQB => s_fimRodada
    );

  registraChaves: registrador_n
    port map (
        clock  => clock,
        clear  => zeraR,
        enable => registraR,
        D      => chaves,
        Q      => s_chaves
    );

  --memoria: entity work.ram_16x4 (ram_mif)  -- usar esta linha para Intel Quartus
   memoria: entity work.ram_16x4 (ram_modelsim) -- usar arquitetura para ModelSim
    port map (                                              --Pronto
       clk          => clock,
       endereco     => s_endereco,
       dado_entrada => valorEscrito,
       we           => s_escreve_not, -- we ativo em baixo
       ce           => '0',
       dado_saida   => s_memoria
    );

  edgeDetector: edge_detector    --EdgeDetector de Jogadas
    port map (
      clock => clock,
      reset => notOrChaves,
      sinal => orChaves,
      pulso => pulso_de_jogada
    );

  timer: contador_m      --Contador to timer
    generic map (M => 5000)
    port map (
      clock   => clock,
      zera_as => '0',
      zera_s  => zeraT, 
      conta   => contaT,   
      Q       => open,
      fim     => fimT,
      meio    => open
    );
  
  timerTransiorio: contador_m      --Contador to timer
    generic map (M => 1500)
    port map (
      clock   => clock,
      zera_as => '0',
      zera_s  => zeraTransitorio, 
      conta   => contaTransitorio,   
      Q       => open,
      fim     => fimTransitorio,
      meio    => open
    );
  
  timerDecrescente: contador_m_decre     --Contador to timer
    generic map (M => 6000)
    port map (
      clock   => clock,
      zera_as => '0',
      zera_s  => zeraTDecre, 
      conta   => contaTDecre,   
      Q       => open,
      fim     => fimTDecre,
      meio    => open,
      rodada  => s_rodada
    );
  
  timerInfinito: contador_m_compar     --Contador to timer
    generic map (M => 2000000)
    port map (
      clock   => clock,
      zera_as => '0',
      zera_s  => zeraTCompar, 
      conta   => contaTCompar,   
      jogadorAtual   => s_rodada(0),   
      Q       => open,
      fim     => open,
      meio    => open,
      jogadorRap  => jogadorRap
    );

  timerLeds: contador_m  --Contador do timer das Leds
    generic map (M => 1000)
    port map (
      clock   => clock,
      zera_as => '0',
      zera_s  => zeraTimerLed, 
      conta   => contaTimerLed,   
      Q       => open,
      fim     => s_mostrouUmaJogada,
      meio    => s_meioDaJogada
    );

  registraModoDeJogo: registrador_n  --Registrador de Nível
  port map (
    clock  => clock,
    clear  => zeraNivel,
    enable => registraNivel,
    D      => chaves,
    Q      => nivelSelecionado
);
  
  fimRodada       <= s_fimRodada;
  mostrouJogada   <= s_fimRodada and s_mostrouUmaJogada;

  fimVidaJogador1 <='1' when s_vidaJogador1="0010" else
                   '0';

  fimVidaJogador2 <='1' when s_vidaJogador2="0010" else
                   '0';

  db_tem_jogada <= orChaves;   
  db_contagem   <= s_endereco;
  db_memoria    <= s_memoria;
  db_jogada     <= s_chaves;
  db_rodada     <= s_rodada;
  rodadaAtual   <= s_rodada;

  vidaAtual1    <= s_vidaJogador1;
  vidaAtual2    <= s_vidaJogador2;

  leds <= chaves    when mostraJogada = '0' else
          s_memoria when mostraJogada = '1' and s_meioDaJogada = '1' else
          "0000";

  valorEscrito <= valorAleatorio when escreveAleatorio = '1' else
                  s_chaves       when escreveAleatorio = '0';


end architecture estrutural;
