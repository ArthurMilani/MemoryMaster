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
use ieee.numeric_std.all;
use ieee.math_real.all;

-- entidade do testbench
entity circuito_jogo_tb_acerto is
end entity;

architecture tb of circuito_jogo_tb_acerto is

  -- Componente a ser testado (Device Under Test -- DUT)
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
  
  ---- Declaracao de sinais de entrada para conectar o componente
  signal clk_in     : std_logic := '0';
  signal zera_as_in    : std_logic := '0';
  signal zera_s_in    : std_logic := '0';
  signal conta_in    : std_logic := '0';
  signal fim_out     : std_logic := '0';
  signal meio_out    : std_logic := '0';
  signal rodada_in   : std_logic_vector(3 downto 0);


  -- Configurações do clock
  signal keep_simulating: std_logic := '0'; -- delimita o tempo de geração do clock
  constant clockPeriod : time := 1 ms;     -- frequencia 1kHz
  
begin
  -- Gerador de clock: executa enquanto 'keep_simulating = 1', com o período especificado. 
  -- Quando keep_simulating=0, clock é interrompido, bem como a simulação de eventos
  clk_in <= (not clk_in) and keep_simulating after clockPeriod/2;
  
  ---- DUT para Simulacao
  dut: contador_m_decre
 
       port map
       (
          clock    => clk_in,
          zera_as  => zera_as_in,
          zera_s   => zera_s_in,
          conta    => conta_in,
          Q        => open,
          fim      => fim_out,
          meio     => open,
          rodada   => rodada_in
       );
 
  ---- Gera sinais de estimulo para a simulacao
  -- Cenario de Teste : acerta as primeiras 4 jogadas
  --                    e erra a 5a jogada
  stimulus: process is
  begin

    -- inicio da simulacao
    assert false report "inicio da simulacao" severity note;
    keep_simulating <= '1';  -- inicia geracao do sinal de clock



    -- espera 6s para inicio dos testes
    rodada_in <= "1111";
    wait for 10*clockPeriod;
    wait until falling_edge(clk_in);

    -- Teste 1
    zera_as_in <= '1';
    wait for 4*clockPeriod;
    zera_as_in <= '0';
    wait for 4*clockPeriod;
    conta_in <= '1';
    wait for 7000*clockPeriod;


    






        
 
    ---- final do testbench
    assert false report "fim da simulacao" severity note;
    keep_simulating <= '0';
    
    wait; -- fim da simulação: processo aguarda indefinidamente
  end process;


end architecture;
