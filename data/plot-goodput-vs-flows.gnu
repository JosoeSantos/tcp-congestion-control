# Configurações gerais
set terminal png size 1200,800 font "Arial,12"
set output 'goodput_vs_flows.png'

set title "Vazão Útil Agregada vs Número de fluxos por endpoint" font "Arial,14"
set xlabel "Número de fluxos" font "Arial,12"
set ylabel "Vazão Útil Agregada (Mbps)" font "Arial,12"

set grid
set key top right

# set logscale x 10
# set logscale y 10
# set format x "10^{%L}"
# set format y "10^{%L}"

# Estilos de linha
set style line 1 lc rgb '#75a9d3' lt 1 lw 2 pt 7 ps 1.5
set style line 2 lc rgb '#196aac' lt 1 lw 2 pt 9 ps 1.5
set style line 3 lc rgb '#02223c' lt 1 lw 2 pt 11 ps 1.5
set style line 4 lc rgb '#de8487' lt 2 lw 2 pt 7 ps 1.5
set style line 5 lc rgb '#dd181f' lt 2 lw 2 pt 9 ps 1.5
set style line 6 lc rgb '#63070a' lt 2 lw 2 pt 11 ps 1.5

# O formato das colunas dos arquivos de dados é:

# nFlow goodput1(bps) goodput1(Mbps) goodput2(bps) goodput2(Mbps)
# Plot
# Extrair apenas o número (remove "ms")
plot './results/part-2/goodput-TcpCubic.data' using 1:3 smooth unique with linespoints ls 2 title 'TCP CUBIC', \
     './results/part-2/goodput-TcpNewReno.data' using 1:5 smooth unique with linespoints ls 5 title 'TCP NewReno', \

