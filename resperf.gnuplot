set title "Resperf Plot"
set xlabel "Time (s)"
set ylabel "QPS"
set grid
set key left top
set terminal png
set output 'resperf_plot.png'

plot 'resperf.dat' using 1:3 with lines title 'Actual QPS', \
     'resperf.dat' using 1:4 with lines title 'Responses per Second', \
     'resperf.dat' using 1:5 with lines title 'Failures per Second'
