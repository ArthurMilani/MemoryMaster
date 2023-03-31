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

        --Modo de Jogo 1
        
        zeraTimerLed        : in  std_logic;                --Reset timer das Leds
        contaTimerLed       : in  std_logic;                --Enable timer das Leds
        mostraJogada        : in  std_logic;                --Enable para mostrar as jogadas a serem feitas
        mostrouJogada       : out std_logic;
        escreve             : in std_logic;
      
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
end entity fluxo_dados;

architecture estrutural of fluxo_dados is

  signal s_endereco    : std_logic_vector (3 downto 0);  --Sinal intermediário: endereço atual
  signal s_memoria     : std_logic_vector (3 downto 0);  --Sinal interemdiario: valor da memória
  signal s_chaves      : std_logic_vector (3 downto 0);  --Sinal intermediário: valor das chaves (pós registrador)
  signal s_rodada      : std_logic_vector (3 downto 0);  --Sinal intermediário: valor da rodada atual
  signal s_not_zeraE   : std_logic;     --Sinal auxiliar: zera é ativo baixo
  signal s_not_zeraCR  : std_logic;     --Sinal auxiliar: zera é ativo baixo 
  signal s_not_escreve : std_logic;     --Sinal auxiliar: escreve é ativo baixo
  signal orChaves      : std_logic;     --Sinal auxiliar: indica  "or" entre as chaves
  signal notOrChaves   : std_logic;     --Sinal auxiliar: indica a "nor" entre as chaves
  signal s_fimRodada   : std_logic;
  signal s_contaE      : std_logic;
  signal s_mostrouUmaJogada : std_logic;
  signal s_meioDaJogada : std_logic;
  signal s_valorAleatorio : std_logic_vector(3 downto 0);

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
  s_not_zeraE   <= not zeraE;
  s_not_zeraCR  <= not zeraCR;
  s_contaE <= s_mostrouUmaJogada or contaE;
  s_not_escreve <= not escreve;

  --or das chaves de entrada
  orChaves <= chaves(3) or chaves(2) or chaves(1) or chaves(0);
  notOrChaves <= not orChaves;
  
  geradorAleatorio: bitvector_generator
    port map(
      clk    => clock,
      rst    => '0',
      output => s_valorAleatorio
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
       dado_entrada => s_valorAleatorio,     --s_chaves,
       we           => s_not_escreve, -- we ativo em baixo 
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
  
  fimRodada <= s_fimRodada;
  mostrouJogada <= s_fimRodada and s_mostrouUmaJogada;


  db_tem_jogada <= orChaves;   
  db_contagem   <= s_endereco;
  db_memoria    <= s_memoria;
  db_jogada     <= s_chaves;
  db_rodada     <= s_rodada;

  leds <= chaves    when mostraJogada = '0' else
          s_memoria when mostraJogada = '1' and s_meioDaJogada = '1' else
          "0000";


end architecture estrutural;
