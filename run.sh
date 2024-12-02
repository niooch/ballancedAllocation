#!/bin/bash
plotujPojedynczy(){
    local gnuplot_skrypt="plot.gnuplot"
    local typ=$1
    local pozycja=$2
    cat > $gnuplot_skrypt << EOF
    set terminal pngcairo size 800,600 enhanced font "Verdana,10"
    set output "$typ.png"
    set datafile separator ";"
    set grid

    set title "Wykres $typ w zależności od n"
    set xlabel "n"
    set ylabel "stosunek"

    plot \
        "ratios.dat" using 1:$pozycja title "$typ" with points pt 7 lc rgb "blue"
EOF
    gnuplot $gnuplot_skrypt
}

plotujPodwojny(){
    local gnuplot_skrypt="plot.gnuplot"
    local typ1=$1
    local pozycja1=$2
    local typ2=$3
    local pozycja2=$4
    cat > $gnuplot_skrypt << EOF
    set terminal pngcairo size 800,600 enhanced font "Verdana,10"
    set output "$typ1-$typ2.png"
    set datafile separator ";"
    set grid

    set title "Wykres $typ1, $typ2 w zależności od n"
    set xlabel "n"
    set ylabel "stosunek"

    plot \
        "ratios.dat" using 1:$pozycja1 title "$typ1" with points pt 7 lc rgb "blue", \
        "ratios.dat" using 1:$pozycja2 title "$typ2" with points pt 7 lc rgb "red"
EOF
    gnuplot $gnuplot_skrypt
}

plotujPotrojony(){
    local gnuplot_skrypt="plot.gnuplot"
    local typ1=$1
    local pozycja1=$2
    local typ2=$3
    local pozycja2=$4
    local typ3=$5
    local pozycja3=$6
    cat > $gnuplot_skrypt << EOF
    set terminal pngcairo size 800,600 enhanced font "Verdana,10"
    set output "$typ1-$typ2-$typ3.png"
    set datafile separator ";"
    set grid

    set title "Wykres $typ1, $typ2, $typ3 w zależności od n"
    set xlabel "n"
    set ylabel "stosunek"

    plot \
        "ratios.dat" using 1:$pozycja1 title "$typ1" with points pt 7 lc rgb "blue", \
        "ratios.dat" using 1:$pozycja2 title "$typ2" with points pt 7 lc rgb "red", \
        "ratios.dat" using 1:$pozycja3 title "$typ3" with points pt 7 lc rgb "green"
EOF
    gnuplot $gnuplot_skrypt
}
plotuj(){
    local gnuplot_skrypt="plot.gnuplot"
    local typ=$1
    local pozycja=$2
    cat > $gnuplot_skrypt << EOF
    set terminal pngcairo size 800,600 enhanced font "Verdana,10"
    set output "$typ.png"
    set datafile separator ";"
    set title "Wykres $typ w zależności od n"
    set xlabel "n"
    set ylabel "$typ"

    set grid

    plot \
        "wyniki.dat" using 1:$pozycja title "$typ" with points pt 7 lc rgb "blue", \
        "srednie.dat" using 1:$pozycja title "Średnia $typ" with points pt 7 lc rgb "red"
EOF

gnuplot $gnuplot_skrypt
}
#skompiluj program
make clean
make

if [ $? -ne 0 ]; then
    echo "Blad kompilacji"
    exit 1
fi

#pobierz dane: sekwencje liczb dla ktorych mamy wykonac symulacje
if [ $# -eq 0 ]; then
    echo "Brak argumentow. uzycie: $0 n1 [n2 n3 ...]"
    exit 1
fi
wartosci_n=$@

#przygotuj plik wynikowy
if [ -f wyniki.dat ]; then
    rm wyniki.dat
fi

#dla kazdej liczby n z argumentow wykonaj symulacje
for n in $wartosci_n; do
    echo "n=$n"
    ./ballsAndBins $n >> wyniki.dat
done

#policz srednie wartosci dla kazdego n:
if [ -f srednie.dat ]; then
    rm srednie.dat
fi

awk -F';' '
BEGIN {
}
{
    n = $1
    for (i = 2; i <= NF; i++) {
        sum[n,i] += $i
        count[n,i] += 1
    }
    num_fields[n] = NF
}
END {
    PROCINFO["sorted_in"] = "@ind_num_asc"  # Sort n numerically ascending
    for (n in num_fields) {
        output = n
        nf = num_fields[n]
        for (i = 2; i <= nf; i++) {
            mean = sum[n,i] / count[n,i]
            output = output ";" sprintf("%.2f", mean)
        }
        print output >> "srednie.dat"
    }
}
' wyniki.dat

#odpal gnuplota
plotuj "B(n)" 2
plotuj "U(n)" 3
plotuj "C(n)" 4
plotuj "D(n)" 5
plotuj "D(n) - C(n)" 6

#jezeli nie istnieje katalog wykresy to go stworz
if [ ! -d wykresy ]; then
    mkdir wykresy
fi
#przenies wykresy do odpowiedniego katalogu
mv *.png ./wykresy/

#policzyc pozostale ciagi

awk -F';' '
BEGIN {
    OFS = ";"
}
{
    n = $1
    b_n = $2
    u_n = $3
    c_n = $4
    d_n = $5

    sqrt_n = sqrt(n)
    ln_n = log(n)
    ln_ln_n = log(ln_n)
    n_ln_n = n * ln_n
    n2 = n * n

    b_n_over_n = b_n / n
    b_n_over_sqrt_n = b_n / sqrt_n
    u_n_over_n = u_n / n
    c_n_over_n = c_n / n
    c_n_over_n_ln_n = (n_ln_n > 0) ? c_n / n_ln_n : 0
    c_n_over_n2 = c_n / n2
    d_n_over_n = d_n / n
    d_n_over_n_ln_n = (n_ln_n > 0) ? d_n / n_ln_n : 0
    d_n_over_n2 = d_n / n2
    d_minus_c = d_n - c_n
    d_minus_c_over_n = d_minus_c / n
    d_minus_c_over_n_ln_n = (n_ln_n > 0) ? d_minus_c / n_ln_n : 0
    d_minus_c_over_n_ln_ln_n = (ln_ln_n > 0) ? d_minus_c / (n * ln_ln_n) : 0

    print n, b_n_over_n, b_n_over_sqrt_n, u_n_over_n, c_n_over_n, c_n_over_n_ln_n, c_n_over_n2, d_n_over_n, d_n_over_n_ln_n, d_n_over_n2, d_minus_c_over_n, d_minus_c_over_n_ln_n, d_minus_c_over_n_ln_ln_n
}
' srednie.dat > ratios.dat


plotujPodwojny "B(n)NAn" 2 "B(n)NAsqrt(n)" 3
plotujPojedynczy "U(n)NAn" 4
plotujPotrojony "C(n)NAn" 5 "C(n)NAnln(n)" 6 "C(n)NAn^2" 7
plotujPotrojony "D(n)NAn" 8 "D(n)NAnln(n)" 9 "D(n)NAn^2" 10
plotujPotrojony "D(n)-C(n)NAn" 11 "D(n)-C(n)NAnln(n)" 12 "D(n)-C(n)NAnln(ln(n))" 13

#przenies wykresy do odpowiedniego katalogu
mv *.png ./wykresy/
