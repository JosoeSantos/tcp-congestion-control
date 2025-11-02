# Configurações gerais
set terminal png size 1200,800 font "Arial,12"
set output 'goodput_vs_delay.png'

set title "Vazão Útil Agregada vs Atraso do Enlace de Gargalo" font "Arial,14"
set xlabel "Atraso do Enlace (ms)" font "Arial,12"
set ylabel "Vazão Útil Agregada (Mbps)" font "Arial,12"

set grid
set key top right

# Estilos de linha
set style line 1 lc rgb '#75a9d3' lt 1 lw 2 pt 7 ps 1.5
set style line 2 lc rgb '#196aac' lt 1 lw 2 pt 9 ps 1.5
set style line 3 lc rgb '#02223c' lt 1 lw 2 pt 11 ps 1.5
set style line 4 lc rgb '#de8487' lt 2 lw 2 pt 7 ps 1.5
set style line 5 lc rgb '#dd181f' lt 2 lw 2 pt 9 ps 1.5
set style line 6 lc rgb '#63070a' lt 2 lw 2 pt 11 ps 1.5

# delay(ms) nFlow goodput(bps) goodput (Mbps)
# Plot
# Extrair apenas o número (remove "ms")
plot './results/part-b/TcpCubic-nFlows-1/goodput-TcpCubic-nFlows-1.data' using (int($1)):4 smooth unique with linespoints ls 1 title 'CUBIC 1 fluxo', \
     './results/part-b/TcpCubic-nFlows-2/goodput-TcpCubic-nFlows-2.data' using (int($1)):4 smooth unique with linespoints ls 2 title 'CUBIC 2 fluxos', \
     './results/part-b/TcpCubic-nFlows-4/goodput-TcpCubic-nFlows-4.data' using (int($1)):4 smooth unique with linespoints ls 3 title 'CUBIC 4 fluxos', \
     './results/part-b/TcpNewReno-nFlows-1/goodput-TcpNewReno-nFlows-1.data' using (int($1)):4 smooth unique with linespoints ls 4 title 'NewReno 1 fluxo', \
     './results/part-b/TcpNewReno-nFlows-2/goodput-TcpNewReno-nFlows-2.data' using (int($1)):4 smooth unique with linespoints ls 5 title 'NewReno 2 fluxos', \
     './results/part-b/TcpNewReno-nFlows-4/goodput-TcpNewReno-nFlows-4.data' using (int($1)):4 smooth unique with linespoints ls 6 title 'NewReno 4 fluxos'
