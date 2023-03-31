onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider Depuração
add wave -noupdate /circuito_jogo_tb_acerto/dut/dataFlux/s_mostrouUmaJogada
add wave -noupdate /circuito_jogo_tb_acerto/dut/dataFlux/s_meioDaJogada
add wave -noupdate /circuito_jogo_tb_acerto/dut/dataFlux/mostrouJogada
add wave -noupdate /circuito_jogo_tb_acerto/dut/dataFlux/mostraJogada
add wave -noupdate -divider Entradas
add wave -noupdate /circuito_jogo_tb_acerto/clk_in
add wave -noupdate /circuito_jogo_tb_acerto/chaves_in
add wave -noupdate /circuito_jogo_tb_acerto/iniciar_in
add wave -noupdate /circuito_jogo_tb_acerto/rst_in
add wave -noupdate -divider Saídas
add wave -noupdate /circuito_jogo_tb_acerto/acertou_out
add wave -noupdate /circuito_jogo_tb_acerto/contagem_out
add wave -noupdate /circuito_jogo_tb_acerto/errou_out
add wave -noupdate /circuito_jogo_tb_acerto/igual_out
add wave -noupdate /circuito_jogo_tb_acerto/pronto_out
add wave -noupdate /circuito_jogo_tb_acerto/leds_out
add wave -noupdate /circuito_jogo_tb_acerto/dut/unityControl/Eatual
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {140264376631463 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 350
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {139023611490262 ps} {140062386891627 ps}
