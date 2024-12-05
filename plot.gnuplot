    set terminal pngcairo size 800,600 enhanced font "Verdana,10"
    set output "Ln2-f2-Ln2OVERf2.png"
    set datafile separator ";"
    set grid

    set title "Wykres Ln2, f2, Ln2OVERf2 w zależności od n"
    set xlabel "n"
    set ylabel "stosunek"

    plot         "ratios.dat" using 1:5 title "Ln2" with points pt 7 lc rgb "blue",         "ratios.dat" using 1:6 title "f2" with points pt 7 lc rgb "red",         "ratios.dat" using 1:7 title "Ln2OVERf2" with points pt 7 lc rgb "green"
