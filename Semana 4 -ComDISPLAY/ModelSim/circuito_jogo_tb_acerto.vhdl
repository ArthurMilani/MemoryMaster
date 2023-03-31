--------------------------------------------------------------------------
-- Arquivo   : circuito_exp4_tb_modelo.vhd
-- Projeto   : Experiencia 04 - Desenvolvimento de Projeto de
--                              Circuitos Digitais com FPGA
--------------------------------------------------------------------------
-- Descricao : modelo de testbench para simulação com ModelSim
--
--             implementa um Cenário de Teste do circuito
--             com 4 jogadas certas e erro na quinta jogada
--------------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     01/02/2020  1.0     Edson Midorikawa  criacao
--     27/01/2021  1.1     Edson Midorikawa  revisao
--     27/01/2022  1.2     Edson Midorikawa  revisao e adaptacao
--------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;

-- entidade do testbench
entity circuito_jogo_tb_acerto is
end entity;

architecture tb of circuito_jogo_tb_acerto is

  -- Componente a ser testado (Device Under Test -- DUT)
  component genius is
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
        end component;
  
  ---- Declaracao de sinais de entrada para conectar o componente
  signal clk_in     : std_logic := '0';
  signal rst_in     : std_logic := '0';
  signal iniciar_in : std_logic := '0';
  signal chaves_in  : std_logic_vector(3 downto 0) := "0000";

  ---- Declaracao dos sinais de saida
  signal igual_out      : std_logic := '0';
  signal acertou_out    : std_logic := '0';
  signal errou_out      : std_logic := '0';
  signal pronto_out     : std_logic := '0';
  signal leds_out       : std_logic_vector(3 downto 0) := "0000";
  signal clock_out      : std_logic := '0';
  signal tem_jogada_out : std_logic := '0';
  signal timeout_out    : std_logic := '0';
  signal display1_out   : std_logic_vector(6 downto 0) := "0000000";
  signal display2_out   : std_logic_vector(6 downto 0) := "0000000";
  signal display3_out   : std_logic_vector(6 downto 0) := "0000000";
  signal display4_out   : std_logic_vector(6 downto 0) := "0000000";
  signal display5_out   : std_logic_vector(6 downto 0) := "0000000";
  signal display6_out   : std_logic_vector(6 downto 0) := "0000000";

  -- Configurações do clock
  signal keep_simulating: std_logic := '0'; -- delimita o tempo de geração do clock
  constant clockPeriod : time := 1 ms;     -- frequencia 1kHz
  
begin
  -- Gerador de clock: executa enquanto 'keep_simulating = 1', com o período especificado. 
  -- Quando keep_simulating=0, clock é interrompido, bem como a simulação de eventos
  clk_in <= (not clk_in) and keep_simulating after clockPeriod/2;
  
  ---- DUT para Simulacao
  dut: genius
       port map
       (
          clock           => clk_in,
          reset           => rst_in,
          iniciar         => iniciar_in,
          chaves          => chaves_in,
          ganhou          => acertou_out,
          perdeu          => errou_out,
          pronto          => pronto_out,
          leds            => leds_out,
          db_igual        => igual_out,
          display1        => display1_out,
          display2        => display2_out,
          display3        => display3_out,
          display4        => display4_out,
          display5        => display5_out,
          display6        => display6_out,  
          db_clock        => clock_out,
          db_tem_jogada   => tem_jogada_out,
          db_timeout      => timeout_out
       );
 
  ---- Gera sinais de estimulo para a simulacao
  -- Cenario de Teste : acerta as primeiras 4 jogadas
  --                    e erra a 5a jogada
  stimulus: process is
  begin

    -- inicio da simulacao
    assert false report "inicio da simulacao" severity note;
    keep_simulating <= '1';  -- inicia geracao do sinal de clock

    -- gera pulso de reset (1 periodo de clock)
    rst_in <= '1';
    wait for clockPeriod;
    rst_in <= '0';


    -- pulso do sinal de Iniciar (muda na borda de descida do clock)
    wait until falling_edge(clk_in);
    iniciar_in <= '1';
    wait until falling_edge(clk_in);
    iniciar_in <= '0';
    
    -- espera 6s para inicio dos testes
    wait for 500*clockPeriod;
    wait until falling_edge(clk_in);

    -- Cenario de Teste - acerta as 4 primeiras jogadas e erra a 5a jogada

    chaves_in <= "0001";
    wait for 7*clockPeriod;
    chaves_in <= "0000";
    wait for 1100*clockPeriod;

--Rodada 1
    
        ---- jogada #1 (chaves=0001 e 15 clocks de duracao)
        chaves_in <= "0001";
        wait for 7*clockPeriod;
        chaves_in <= "0000";
        -- espera entre jogadas de 10 clocks
        wait for 2100*clockPeriod; 

--Rodada 2

        ---- jogada #1 (chaves=0001 e 15 clocks de duracao)
        chaves_in <= "0001";
        wait for 7*clockPeriod;
        chaves_in <= "0000";
        -- espera entre jogadas de 10 clocks
        wait for 10*clockPeriod;  
    
        ---- jogada #2 (chaves=0010 e 5 clocks de duracao)
        chaves_in <= "0010";
        wait for 7*clockPeriod;
        chaves_in <= "0000";
        ---- espera entre jogadas
        wait for 3100*clockPeriod;
     


--Rodada 3

            ---- jogada #1 (chaves=0001 e 15 clocks de duracao)
    chaves_in <= "0001";
    wait for 7*clockPeriod;
    chaves_in <= "0000";
    -- espera entre jogadas de 10 clocks
    wait for 10*clockPeriod;  

    ---- jogada #2 (chaves=0010 e 5 clocks de duracao)
    chaves_in <= "0010";
    wait for 7*clockPeriod;
    chaves_in <= "0000";
    ---- espera entre jogadas
    wait for 10*clockPeriod;
 
    ---- jogada #3 (chaves=0100 e 7 clocks de duracao)
    chaves_in <= "0100";
    wait for 7*clockPeriod;
    chaves_in <= "0000";
    -- espera entre jogadas
    wait for 4100*clockPeriod;  


--Rodada 4

        ---- jogada #1 (chaves=0001 e 15 clocks de duracao)
        chaves_in <= "0001";
        wait for 7*clockPeriod;
        chaves_in <= "0000";
        -- espera entre jogadas de 10 clocks
        wait for 10*clockPeriod;  
    
        ---- jogada #2 (chaves=0010 e 5 clocks de duracao)
        chaves_in <= "0010";
        wait for 7*clockPeriod;
        chaves_in <= "0000";
        ---- espera entre jogadas
        wait for 10*clockPeriod;
     
        ---- jogada #3 (chaves=0100 e 7 clocks de duracao)
        chaves_in <= "0100";
        wait for 7*clockPeriod;
        chaves_in <= "0000";
        -- espera entre jogadas
        wait for 10*clockPeriod;  
    
        ---- jogada #4 (chaves=1000 e 7 clocks de duracao)
        chaves_in <= "1000";
        wait for 7*clockPeriod;
        chaves_in <= "0000";
        ---- espera entre jogadas
        wait for 5100*clockPeriod;
    


--Rodada 5

            ---- jogada #1 (chaves=0001 e 15 clocks de duracao)
    chaves_in <= "0001";
    wait for 7*clockPeriod;
    chaves_in <= "0000";
    -- espera entre jogadas de 10 clocks
    wait for 10*clockPeriod;  

    ---- jogada #2 (chaves=0010 e 5 clocks de duracao)
    chaves_in <= "0010";
    wait for 7*clockPeriod;
    chaves_in <= "0000";
    ---- espera entre jogadas
    wait for 10*clockPeriod;
 
    ---- jogada #3 (chaves=0100 e 7 clocks de duracao)
    chaves_in <= "0100";
    wait for 7*clockPeriod;
    chaves_in <= "0000";
    -- espera entre jogadas
    wait for 10*clockPeriod;  

    ---- jogada #4 (chaves=1000 e 7 clocks de duracao)
    chaves_in <= "1000";
    wait for 7*clockPeriod;
    chaves_in <= "0000";
    ---- espera entre jogadas
    wait for 10*clockPeriod;

    ---- jogada #5 (chaves=0100 e 7 clocks de duracao)
    chaves_in <= "0100";
    wait for 7*clockPeriod;
    chaves_in <= "0000";
    -- espera entre jogadas
    wait for 6100*clockPeriod; 



--Rodada 6

        ---- jogada #1 (chaves=0001 e 15 clocks de duracao)
        chaves_in <= "0001";
        wait for 7*clockPeriod;
        chaves_in <= "0000";
        -- espera entre jogadas de 10 clocks
        wait for 10*clockPeriod;  
    
        ---- jogada #2 (chaves=0010 e 5 clocks de duracao)
        chaves_in <= "0010";
        wait for 7*clockPeriod;
        chaves_in <= "0000";
        ---- espera entre jogadas
        wait for 10*clockPeriod;
     
        ---- jogada #3 (chaves=0100 e 7 clocks de duracao)
        chaves_in <= "0100";
        wait for 7*clockPeriod;
        chaves_in <= "0000";
        -- espera entre jogadas
        wait for 10*clockPeriod;  
    
        ---- jogada #4 (chaves=1000 e 7 clocks de duracao)
        chaves_in <= "1000";
        wait for 7*clockPeriod;
        chaves_in <= "0000";
        ---- espera entre jogadas
        wait for 10*clockPeriod;
    
        ---- jogada #5 (chaves=0100 e 7 clocks de duracao)
        chaves_in <= "0100";
        wait for 7*clockPeriod;
        chaves_in <= "0000";
        -- espera entre jogadas
        wait for 10*clockPeriod; 
    
        ---- jogada #6 (chaves=0010 e 7 clocks de duracao)
        chaves_in <= "0010";
        wait for 7*clockPeriod;
        chaves_in <= "0000";
        -- espera entre jogadas
        wait for 7100*clockPeriod; 
    


--Rodada 7
            ---- jogada #1 (chaves=0001 e 15 clocks de duracao)
    chaves_in <= "0001";
    wait for 7*clockPeriod;
    chaves_in <= "0000";
    -- espera entre jogadas de 10 clocks
    wait for 10*clockPeriod;  

    ---- jogada #2 (chaves=0010 e 5 clocks de duracao)
    chaves_in <= "0010";
    wait for 7*clockPeriod;
    chaves_in <= "0000";
    ---- espera entre jogadas
    wait for 10*clockPeriod;
 
    ---- jogada #3 (chaves=0100 e 7 clocks de duracao)
    chaves_in <= "0100";
    wait for 7*clockPeriod;
    chaves_in <= "0000";
    -- espera entre jogadas
    wait for 10*clockPeriod;  

    ---- jogada #4 (chaves=1000 e 7 clocks de duracao)
    chaves_in <= "1000";
    wait for 7*clockPeriod;
    chaves_in <= "0000";
    ---- espera entre jogadas
    wait for 10*clockPeriod;

    ---- jogada #5 (chaves=0100 e 7 clocks de duracao)
    chaves_in <= "0100";
    wait for 7*clockPeriod;
    chaves_in <= "0000";
    -- espera entre jogadas
    wait for 10*clockPeriod; 

    ---- jogada #6 (chaves=0010 e 7 clocks de duracao)
    chaves_in <= "0010";
    wait for 7*clockPeriod;
    chaves_in <= "0000";
    -- espera entre jogadas
    wait for 10*clockPeriod; 

    ---- jogada #7 (chaves=0001 e 7 clocks de duracao)
    chaves_in <= "0001";
    wait for 7*clockPeriod;
    chaves_in <= "0000";
    -- espera entre jogadas
    wait for 8100*clockPeriod; 



--Rodada 8

        ---- jogada #1 (chaves=0001 e 15 clocks de duracao)
        chaves_in <= "0001";
        wait for 7*clockPeriod;
        chaves_in <= "0000";
        -- espera entre jogadas de 10 clocks
        wait for 10*clockPeriod;  
    
        ---- jogada #2 (chaves=0010 e 5 clocks de duracao)
        chaves_in <= "0010";
        wait for 7*clockPeriod;
        chaves_in <= "0000";
        ---- espera entre jogadas
        wait for 10*clockPeriod;
     
        ---- jogada #3 (chaves=0100 e 7 clocks de duracao)
        chaves_in <= "0100";
        wait for 7*clockPeriod;
        chaves_in <= "0000";
        -- espera entre jogadas
        wait for 10*clockPeriod;  
    
        ---- jogada #4 (chaves=1000 e 7 clocks de duracao)
        chaves_in <= "1000";
        wait for 7*clockPeriod;
        chaves_in <= "0000";
        ---- espera entre jogadas
        wait for 10*clockPeriod;
    
        ---- jogada #5 (chaves=0100 e 7 clocks de duracao)
        chaves_in <= "0100";
        wait for 7*clockPeriod;
        chaves_in <= "0000";
        -- espera entre jogadas
        wait for 10*clockPeriod; 
    
        ---- jogada #6 (chaves=0010 e 7 clocks de duracao)
        chaves_in <= "0010";
        wait for 7*clockPeriod;
        chaves_in <= "0000";
        -- espera entre jogadas
        wait for 10*clockPeriod; 
    
        ---- jogada #7 (chaves=0001 e 7 clocks de duracao)
        chaves_in <= "0001";
        wait for 7*clockPeriod;
        chaves_in <= "0000";
        -- espera entre jogadas
        wait for 10*clockPeriod; 
    
        ---- jogada #8 (chaves=0001 e 7 clocks de duracao)
        chaves_in <= "0001";
        wait for 7*clockPeriod;
        chaves_in <= "0000";
        -- espera entre jogadas
        wait for 9100*clockPeriod; 
    


--Rodada 9
            ---- jogada #1 (chaves=0001 e 15 clocks de duracao)
    chaves_in <= "0001";
    wait for 7*clockPeriod;
    chaves_in <= "0000";
    -- espera entre jogadas de 10 clocks
    wait for 10*clockPeriod;  

    ---- jogada #2 (chaves=0010 e 5 clocks de duracao)
    chaves_in <= "0010";
    wait for 7*clockPeriod;
    chaves_in <= "0000";
    ---- espera entre jogadas
    wait for 10*clockPeriod;
 
    ---- jogada #3 (chaves=0100 e 7 clocks de duracao)
    chaves_in <= "0100";
    wait for 7*clockPeriod;
    chaves_in <= "0000";
    -- espera entre jogadas
    wait for 10*clockPeriod;  

    ---- jogada #4 (chaves=1000 e 7 clocks de duracao)
    chaves_in <= "1000";
    wait for 7*clockPeriod;
    chaves_in <= "0000";
    ---- espera entre jogadas
    wait for 10*clockPeriod;

    ---- jogada #5 (chaves=0100 e 7 clocks de duracao)
    chaves_in <= "0100";
    wait for 7*clockPeriod;
    chaves_in <= "0000";
    -- espera entre jogadas
    wait for 10*clockPeriod; 

    ---- jogada #6 (chaves=0010 e 7 clocks de duracao)
    chaves_in <= "0010";
    wait for 7*clockPeriod;
    chaves_in <= "0000";
    -- espera entre jogadas
    wait for 10*clockPeriod; 

    ---- jogada #7 (chaves=0001 e 7 clocks de duracao)
    chaves_in <= "0001";
    wait for 7*clockPeriod;
    chaves_in <= "0000";
    -- espera entre jogadas
    wait for 10*clockPeriod; 

    ---- jogada #8 (chaves=0001 e 7 clocks de duracao)
    chaves_in <= "0001";
    wait for 7*clockPeriod;
    chaves_in <= "0000";
    -- espera entre jogadas
    wait for 10*clockPeriod; 

    ---- jogada #9 (chaves=0010 e 7 clocks de duracao)
    chaves_in <= "0010";
    wait for 7*clockPeriod;
    chaves_in <= "0000";
    -- espera entre jogadas
    wait for 10100*clockPeriod; 



--Rodada 10

        ---- jogada #1 (chaves=0001 e 15 clocks de duracao)
        chaves_in <= "0001";
        wait for 7*clockPeriod;
        chaves_in <= "0000";
        -- espera entre jogadas de 10 clocks
        wait for 10*clockPeriod;  
    
        ---- jogada #2 (chaves=0010 e 5 clocks de duracao)
        chaves_in <= "0010";
        wait for 7*clockPeriod;
        chaves_in <= "0000";
        ---- espera entre jogadas
        wait for 10*clockPeriod;
     
        ---- jogada #3 (chaves=0100 e 7 clocks de duracao)
        chaves_in <= "0100";
        wait for 7*clockPeriod;
        chaves_in <= "0000";
        -- espera entre jogadas
        wait for 10*clockPeriod;  
    
        ---- jogada #4 (chaves=1000 e 7 clocks de duracao)
        chaves_in <= "1000";
        wait for 7*clockPeriod;
        chaves_in <= "0000";
        ---- espera entre jogadas
        wait for 10*clockPeriod;
    
        ---- jogada #5 (chaves=0100 e 7 clocks de duracao)
        chaves_in <= "0100";
        wait for 7*clockPeriod;
        chaves_in <= "0000";
        -- espera entre jogadas
        wait for 10*clockPeriod; 
    
        ---- jogada #6 (chaves=0010 e 7 clocks de duracao)
        chaves_in <= "0010";
        wait for 7*clockPeriod;
        chaves_in <= "0000";
        -- espera entre jogadas
        wait for 10*clockPeriod; 
    
        ---- jogada #7 (chaves=0001 e 7 clocks de duracao)
        chaves_in <= "0001";
        wait for 7*clockPeriod;
        chaves_in <= "0000";
        -- espera entre jogadas
        wait for 10*clockPeriod; 
    
        ---- jogada #8 (chaves=0001 e 7 clocks de duracao)
        chaves_in <= "0001";
        wait for 7*clockPeriod;
        chaves_in <= "0000";
        -- espera entre jogadas
        wait for 10*clockPeriod; 
    
        ---- jogada #9 (chaves=0010 e 7 clocks de duracao)
        chaves_in <= "0010";
        wait for 7*clockPeriod;
        chaves_in <= "0000";
        -- espera entre jogadas
        wait for 10*clockPeriod; 
    
        ---- jogada #10 (chaves=0010 e 7 clocks de duracao)
        chaves_in <= "0010";
        wait for 7*clockPeriod;
        chaves_in <= "0000";
        -- espera entre jogadas
        wait for 11100*clockPeriod; 
    


   --Rodada 11
            ---- jogada #1 (chaves=0001 e 15 clocks de duracao)
    chaves_in <= "0001";
    wait for 7*clockPeriod;
    chaves_in <= "0000";
    -- espera entre jogadas de 10 clocks
    wait for 10*clockPeriod;  

    ---- jogada #2 (chaves=0010 e 5 clocks de duracao)
    chaves_in <= "0010";
    wait for 7*clockPeriod;
    chaves_in <= "0000";
    ---- espera entre jogadas
    wait for 10*clockPeriod;
 
    ---- jogada #3 (chaves=0100 e 7 clocks de duracao)
    chaves_in <= "0100";
    wait for 7*clockPeriod;
    chaves_in <= "0000";
    -- espera entre jogadas
    wait for 10*clockPeriod;  

    ---- jogada #4 (chaves=1000 e 7 clocks de duracao)
    chaves_in <= "1000";
    wait for 7*clockPeriod;
    chaves_in <= "0000";
    ---- espera entre jogadas
    wait for 10*clockPeriod;

    ---- jogada #5 (chaves=0100 e 7 clocks de duracao)
    chaves_in <= "0100";
    wait for 7*clockPeriod;
    chaves_in <= "0000";
    -- espera entre jogadas
    wait for 10*clockPeriod; 

    ---- jogada #6 (chaves=0010 e 7 clocks de duracao)
    chaves_in <= "0010";
    wait for 7*clockPeriod;
    chaves_in <= "0000";
    -- espera entre jogadas
    wait for 10*clockPeriod; 

    ---- jogada #7 (chaves=0001 e 7 clocks de duracao)
    chaves_in <= "0001";
    wait for 7*clockPeriod;
    chaves_in <= "0000";
    -- espera entre jogadas
    wait for 10*clockPeriod; 

    ---- jogada #8 (chaves=0001 e 7 clocks de duracao)
    chaves_in <= "0001";
    wait for 7*clockPeriod;
    chaves_in <= "0000";
    -- espera entre jogadas
    wait for 10*clockPeriod; 

    ---- jogada #9 (chaves=0010 e 7 clocks de duracao)
    chaves_in <= "0010";
    wait for 7*clockPeriod;
    chaves_in <= "0000";
    -- espera entre jogadas
    wait for 10*clockPeriod; 

    ---- jogada #10 (chaves=0010 e 7 clocks de duracao)
    chaves_in <= "0010";
    wait for 7*clockPeriod;
    chaves_in <= "0000";
    -- espera entre jogadas
    wait for 10*clockPeriod; 

    ---- jogada #11 (chaves=0100 e 7 clocks de duracao)
    chaves_in <= "0100";
    wait for 7*clockPeriod;
    chaves_in <= "0000";
    -- espera entre jogadas
    wait for 12100*clockPeriod; 
 

      --Rodada 12

        ---- jogada #1 (chaves=0001 e 15 clocks de duracao)
        chaves_in <= "0001";
        wait for 7*clockPeriod;
        chaves_in <= "0000";
        -- espera entre jogadas de 10 clocks
        wait for 10*clockPeriod;  
    
        ---- jogada #2 (chaves=0010 e 5 clocks de duracao)
        chaves_in <= "0010";
        wait for 7*clockPeriod;
        chaves_in <= "0000";
        ---- espera entre jogadas
        wait for 10*clockPeriod;
     
        ---- jogada #3 (chaves=0100 e 7 clocks de duracao)
        chaves_in <= "0100";
        wait for 7*clockPeriod;
        chaves_in <= "0000";
        -- espera entre jogadas
        wait for 10*clockPeriod;  
    
        ---- jogada #4 (chaves=1000 e 7 clocks de duracao)
        chaves_in <= "1000";
        wait for 7*clockPeriod;
        chaves_in <= "0000";
        ---- espera entre jogadas
        wait for 10*clockPeriod;
    
        ---- jogada #5 (chaves=0100 e 7 clocks de duracao)
        chaves_in <= "0100";
        wait for 7*clockPeriod;
        chaves_in <= "0000";
        -- espera entre jogadas
        wait for 10*clockPeriod; 
    
        ---- jogada #6 (chaves=0010 e 7 clocks de duracao)
        chaves_in <= "0010";
        wait for 7*clockPeriod;
        chaves_in <= "0000";
        -- espera entre jogadas
        wait for 10*clockPeriod; 
    
        ---- jogada #7 (chaves=0001 e 7 clocks de duracao)
        chaves_in <= "0001";
        wait for 7*clockPeriod;
        chaves_in <= "0000";
        -- espera entre jogadas
        wait for 10*clockPeriod; 
    
        ---- jogada #8 (chaves=0001 e 7 clocks de duracao)
        chaves_in <= "0001";
        wait for 7*clockPeriod;
        chaves_in <= "0000";
        -- espera entre jogadas
        wait for 10*clockPeriod; 
    
        ---- jogada #9 (chaves=0010 e 7 clocks de duracao)
        chaves_in <= "0010";
        wait for 7*clockPeriod;
        chaves_in <= "0000";
        -- espera entre jogadas
        wait for 10*clockPeriod; 
    
        ---- jogada #10 (chaves=0010 e 7 clocks de duracao)
        chaves_in <= "0010";
        wait for 7*clockPeriod;
        chaves_in <= "0000";
        -- espera entre jogadas
        wait for 10*clockPeriod; 
    
        ---- jogada #11 (chaves=0100 e 7 clocks de duracao)
        chaves_in <= "0100";
        wait for 7*clockPeriod;
        chaves_in <= "0000";
        -- espera entre jogadas
        wait for 10*clockPeriod; 
     
        ---- jogada #12 (chaves=0100 e 7 clocks de duracao)
        chaves_in <= "0100";
        wait for 7*clockPeriod;
        chaves_in <= "0000";
        -- espera entre jogadas
        wait for 13100*clockPeriod; 
        



     --Rodada 13
            ---- jogada #1 (chaves=0001 e 15 clocks de duracao)
    chaves_in <= "0001";
    wait for 7*clockPeriod;
    chaves_in <= "0000";
    -- espera entre jogadas de 10 clocks
    wait for 10*clockPeriod;  

    ---- jogada #2 (chaves=0010 e 5 clocks de duracao)
    chaves_in <= "0010";
    wait for 7*clockPeriod;
    chaves_in <= "0000";
    ---- espera entre jogadas
    wait for 10*clockPeriod;
 
    ---- jogada #3 (chaves=0100 e 7 clocks de duracao)
    chaves_in <= "0100";
    wait for 7*clockPeriod;
    chaves_in <= "0000";
    -- espera entre jogadas
    wait for 10*clockPeriod;  

    ---- jogada #4 (chaves=1000 e 7 clocks de duracao)
    chaves_in <= "1000";
    wait for 7*clockPeriod;
    chaves_in <= "0000";
    ---- espera entre jogadas
    wait for 10*clockPeriod;

    ---- jogada #5 (chaves=0100 e 7 clocks de duracao)
    chaves_in <= "0100";
    wait for 7*clockPeriod;
    chaves_in <= "0000";
    -- espera entre jogadas
    wait for 10*clockPeriod; 

    ---- jogada #6 (chaves=0010 e 7 clocks de duracao)
    chaves_in <= "0010";
    wait for 7*clockPeriod;
    chaves_in <= "0000";
    -- espera entre jogadas
    wait for 10*clockPeriod; 

    ---- jogada #7 (chaves=0001 e 7 clocks de duracao)
    chaves_in <= "0001";
    wait for 7*clockPeriod;
    chaves_in <= "0000";
    -- espera entre jogadas
    wait for 10*clockPeriod; 

    ---- jogada #8 (chaves=0001 e 7 clocks de duracao)
    chaves_in <= "0001";
    wait for 7*clockPeriod;
    chaves_in <= "0000";
    -- espera entre jogadas
    wait for 10*clockPeriod; 

    ---- jogada #9 (chaves=0010 e 7 clocks de duracao)
    chaves_in <= "0010";
    wait for 7*clockPeriod;
    chaves_in <= "0000";
    -- espera entre jogadas
    wait for 10*clockPeriod; 

    ---- jogada #10 (chaves=0010 e 7 clocks de duracao)
    chaves_in <= "0010";
    wait for 7*clockPeriod;
    chaves_in <= "0000";
    -- espera entre jogadas
    wait for 10*clockPeriod; 

    ---- jogada #11 (chaves=0100 e 7 clocks de duracao)
    chaves_in <= "0100";
    wait for 7*clockPeriod;
    chaves_in <= "0000";
    -- espera entre jogadas
    wait for 10*clockPeriod; 
 
    ---- jogada #12 (chaves=0100 e 7 clocks de duracao)
    chaves_in <= "0100";
    wait for 7*clockPeriod;
    chaves_in <= "0000";
    -- espera entre jogadas
    wait for 10*clockPeriod; 
    
    ---- jogada #13 (chaves=1000 e 7 clocks de duracao)
    chaves_in <= "1000";
    wait for 7*clockPeriod;
    chaves_in <= "0000";
    -- espera entre jogadas
    wait for 14010*clockPeriod; 
    

--Rodada 14
        ---- jogada #1 (chaves=0001 e 15 clocks de duracao)
        chaves_in <= "0001";
        wait for 7*clockPeriod;
        chaves_in <= "0000";
        -- espera entre jogadas de 10 clocks
        wait for 10*clockPeriod;  
    
        ---- jogada #2 (chaves=0010 e 5 clocks de duracao)
        chaves_in <= "0010";
        wait for 7*clockPeriod;
        chaves_in <= "0000";
        ---- espera entre jogadas
        wait for 10*clockPeriod;
     
        ---- jogada #3 (chaves=0100 e 7 clocks de duracao)
        chaves_in <= "0100";
        wait for 7*clockPeriod;
        chaves_in <= "0000";
        -- espera entre jogadas
        wait for 10*clockPeriod;  
    
        ---- jogada #4 (chaves=1000 e 7 clocks de duracao)
        chaves_in <= "1000";
        wait for 7*clockPeriod;
        chaves_in <= "0000";
        ---- espera entre jogadas
        wait for 10*clockPeriod;
    
        ---- jogada #5 (chaves=0100 e 7 clocks de duracao)
        chaves_in <= "0100";
        wait for 7*clockPeriod;
        chaves_in <= "0000";
        -- espera entre jogadas
        wait for 10*clockPeriod; 
    
        ---- jogada #6 (chaves=0010 e 7 clocks de duracao)
        chaves_in <= "0010";
        wait for 7*clockPeriod;
        chaves_in <= "0000";
        -- espera entre jogadas
        wait for 10*clockPeriod; 
    
        ---- jogada #7 (chaves=0001 e 7 clocks de duracao)
        chaves_in <= "0001";
        wait for 7*clockPeriod;
        chaves_in <= "0000";
        -- espera entre jogadas
        wait for 10*clockPeriod; 
    
        ---- jogada #8 (chaves=0001 e 7 clocks de duracao)
        chaves_in <= "0001";
        wait for 7*clockPeriod;
        chaves_in <= "0000";
        -- espera entre jogadas
        wait for 10*clockPeriod; 
    
        ---- jogada #9 (chaves=0010 e 7 clocks de duracao)
        chaves_in <= "0010";
        wait for 7*clockPeriod;
        chaves_in <= "0000";
        -- espera entre jogadas
        wait for 10*clockPeriod; 
    
        ---- jogada #10 (chaves=0010 e 7 clocks de duracao)
        chaves_in <= "0010";
        wait for 7*clockPeriod;
        chaves_in <= "0000";
        -- espera entre jogadas
        wait for 10*clockPeriod; 
    
        ---- jogada #11 (chaves=0100 e 7 clocks de duracao)
        chaves_in <= "0100";
        wait for 7*clockPeriod;
        chaves_in <= "0000";
        -- espera entre jogadas
        wait for 10*clockPeriod; 
     
        ---- jogada #12 (chaves=0100 e 7 clocks de duracao)
        chaves_in <= "0100";
        wait for 7*clockPeriod;
        chaves_in <= "0000";
        -- espera entre jogadas
        wait for 10*clockPeriod; 
        
        ---- jogada #13 (chaves=1000 e 7 clocks de duracao)
        chaves_in <= "1000";
        wait for 7*clockPeriod;
        chaves_in <= "0000";
        -- espera entre jogadas
        wait for 10*clockPeriod; 
        
        ---- jogada #14 (chaves=1000 e 7 clocks de duracao)
        chaves_in <= "1000";
        wait for 7*clockPeriod;
        chaves_in <= "0000";
        -- espera entre jogadas
        wait for 15100*clockPeriod; 
    

     --Rodada 15
            ---- jogada #1 (chaves=0001 e 15 clocks de duracao)
    chaves_in <= "0001";
    wait for 7*clockPeriod;
    chaves_in <= "0000";
    -- espera entre jogadas de 10 clocks
    wait for 10*clockPeriod;  

    ---- jogada #2 (chaves=0010 e 5 clocks de duracao)
    chaves_in <= "0010";
    wait for 7*clockPeriod;
    chaves_in <= "0000";
    ---- espera entre jogadas
    wait for 10*clockPeriod;
 
    ---- jogada #3 (chaves=0100 e 7 clocks de duracao)
    chaves_in <= "0100";
    wait for 7*clockPeriod;
    chaves_in <= "0000";
    -- espera entre jogadas
    wait for 10*clockPeriod;  

    ---- jogada #4 (chaves=1000 e 7 clocks de duracao)
    chaves_in <= "1000";
    wait for 7*clockPeriod;
    chaves_in <= "0000";
    ---- espera entre jogadas
    wait for 10*clockPeriod;

    ---- jogada #5 (chaves=0100 e 7 clocks de duracao)
    chaves_in <= "0100";
    wait for 7*clockPeriod;
    chaves_in <= "0000";
    -- espera entre jogadas
    wait for 10*clockPeriod; 

    ---- jogada #6 (chaves=0010 e 7 clocks de duracao)
    chaves_in <= "0010";
    wait for 7*clockPeriod;
    chaves_in <= "0000";
    -- espera entre jogadas
    wait for 10*clockPeriod; 

    ---- jogada #7 (chaves=0001 e 7 clocks de duracao)
    chaves_in <= "0001";
    wait for 7*clockPeriod;
    chaves_in <= "0000";
    -- espera entre jogadas
    wait for 10*clockPeriod; 

    ---- jogada #8 (chaves=0001 e 7 clocks de duracao)
    chaves_in <= "0001";
    wait for 7*clockPeriod;
    chaves_in <= "0000";
    -- espera entre jogadas
    wait for 10*clockPeriod; 

    ---- jogada #9 (chaves=0010 e 7 clocks de duracao)
    chaves_in <= "0010";
    wait for 7*clockPeriod;
    chaves_in <= "0000";
    -- espera entre jogadas
    wait for 10*clockPeriod; 

    ---- jogada #10 (chaves=0010 e 7 clocks de duracao)
    chaves_in <= "0010";
    wait for 7*clockPeriod;
    chaves_in <= "0000";
    -- espera entre jogadas
    wait for 10*clockPeriod; 

    ---- jogada #11 (chaves=0100 e 7 clocks de duracao)
    chaves_in <= "0100";
    wait for 7*clockPeriod;
    chaves_in <= "0000";
    -- espera entre jogadas
    wait for 10*clockPeriod; 
 
    ---- jogada #12 (chaves=0100 e 7 clocks de duracao)
    chaves_in <= "0100";
    wait for 7*clockPeriod;
    chaves_in <= "0000";
    -- espera entre jogadas
    wait for 10*clockPeriod; 
    
    ---- jogada #13 (chaves=1000 e 7 clocks de duracao)
    chaves_in <= "1000";
    wait for 7*clockPeriod;
    chaves_in <= "0000";
    -- espera entre jogadas
    wait for 10*clockPeriod; 
    
    ---- jogada #14 (chaves=1000 e 7 clocks de duracao)
    chaves_in <= "1000";
    wait for 7*clockPeriod;
    chaves_in <= "0000";
    -- espera entre jogadas
    wait for 10*clockPeriod; 

    ---- jogada #15 (chaves=0001 e 7 clocks de duracao)
    chaves_in <= "0001";
    wait for 7*clockPeriod;
    chaves_in <= "0000";
    -- espera entre jogadas
    wait for 16100*clockPeriod; 


       --Rodada 16
        ---- jogada #1 (chaves=0001 e 15 clocks de duracao)
        chaves_in <= "0001";
        wait for 7*clockPeriod;
        chaves_in <= "0000";
        -- espera entre jogadas de 10 clocks
        wait for 10*clockPeriod;  
    
        ---- jogada #2 (chaves=0010 e 5 clocks de duracao)
        chaves_in <= "0010";
        wait for 7*clockPeriod;
        chaves_in <= "0000";
        ---- espera entre jogadas
        wait for 10*clockPeriod;
     
        ---- jogada #3 (chaves=0100 e 7 clocks de duracao)
        chaves_in <= "0100";
        wait for 7*clockPeriod;
        chaves_in <= "0000";
        -- espera entre jogadas
        wait for 10*clockPeriod;  
    
        ---- jogada #4 (chaves=1000 e 7 clocks de duracao)
        chaves_in <= "1000";
        wait for 7*clockPeriod;
        chaves_in <= "0000";
        ---- espera entre jogadas
        wait for 10*clockPeriod;
    
        ---- jogada #5 (chaves=0100 e 7 clocks de duracao)
        chaves_in <= "0100";
        wait for 7*clockPeriod;
        chaves_in <= "0000";
        -- espera entre jogadas
        wait for 10*clockPeriod; 
    
        ---- jogada #6 (chaves=0010 e 7 clocks de duracao)
        chaves_in <= "0010";
        wait for 7*clockPeriod;
        chaves_in <= "0000";
        -- espera entre jogadas
        wait for 10*clockPeriod; 
    
        ---- jogada #7 (chaves=0001 e 7 clocks de duracao)
        chaves_in <= "0001";
        wait for 7*clockPeriod;
        chaves_in <= "0000";
        -- espera entre jogadas
        wait for 10*clockPeriod; 
    
        ---- jogada #8 (chaves=0001 e 7 clocks de duracao)
        chaves_in <= "0001";
        wait for 7*clockPeriod;
        chaves_in <= "0000";
        -- espera entre jogadas
        wait for 10*clockPeriod; 
    
        ---- jogada #9 (chaves=0010 e 7 clocks de duracao)
        chaves_in <= "0010";
        wait for 7*clockPeriod;
        chaves_in <= "0000";
        -- espera entre jogadas
        wait for 10*clockPeriod; 
    
        ---- jogada #10 (chaves=0010 e 7 clocks de duracao)
        chaves_in <= "0010";
        wait for 7*clockPeriod;
        chaves_in <= "0000";
        -- espera entre jogadas
        wait for 10*clockPeriod; 
    
        ---- jogada #11 (chaves=0100 e 7 clocks de duracao)
        chaves_in <= "0100";
        wait for 7*clockPeriod;
        chaves_in <= "0000";
        -- espera entre jogadas
        wait for 10*clockPeriod; 
     
        ---- jogada #12 (chaves=0100 e 7 clocks de duracao)
        chaves_in <= "0100";
        wait for 7*clockPeriod;
        chaves_in <= "0000";
        -- espera entre jogadas
        wait for 10*clockPeriod; 
        
        ---- jogada #13 (chaves=1000 e 7 clocks de duracao)
        chaves_in <= "1000";
        wait for 7*clockPeriod;
        chaves_in <= "0000";
        -- espera entre jogadas
        wait for 10*clockPeriod; 
        
        ---- jogada #14 (chaves=1000 e 7 clocks de duracao)
        chaves_in <= "1000";
        wait for 7*clockPeriod;
        chaves_in <= "0000";
        -- espera entre jogadas
        wait for 10*clockPeriod; 
    
        ---- jogada #15 (chaves=0001 e 7 clocks de duracao)
        chaves_in <= "0001";
        wait for 7*clockPeriod;
        chaves_in <= "0000";
        -- espera entre jogadas
        wait for 10*clockPeriod; 
    
        ---- jogada #16 (chaves=0100 e 7 clocks de duracao)
        chaves_in <= "0100";
        wait for 7*clockPeriod;
        chaves_in <= "0000";
        -- espera entre jogadas
        wait for 20*clockPeriod;


        
 
    ---- final do testbench
    assert false report "fim da simulacao" severity note;
    keep_simulating <= '0';
    
    wait; -- fim da simulação: processo aguarda indefinidamente
  end process;


end architecture;
