#!/bin/bash
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
    local rodzaj=$3
    cat > $gnuplot_skrypt << EOF
    set terminal pngcairo size 800,600 enhanced font "Verdana,10"
    set output "$typ.png"
    set datafile separator ";"
    set title "Wykres $typ w zależności od n"
    set xlabel "n"
    set ylabel "$typ"

    set grid

    plot \
        "wyniki$rodzaj.dat" using 1:$pozycja title "$typ" with points pt 7 lc rgb "blue", \
        "srednie$rodzaj.dat" using 1:$pozycja title "Średnia $typ" with points pt 7 lc rgb "red"
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
if [ -f wynikiA.dat ]; then
    rm wynikiA.dat
fi

if [ -f wynikiB.dat ]; then
    rm wynikiB.dat
fi

#dla kazdej liczby n z argumentow wykonaj symulacje
for n in $wartosci_n; do
    echo "n=$n $(date +"%T")"
    ./ballancedAllocation $n 1 >> wynikiA.dat
done

for n in $wartosci_n; do
    echo "n=$n $(date +"%T")"
    ./ballancedAllocation $n 2 >> wynikiB.dat
done
#wyniki sa zapisane jako n;Ln\n

#policz srednie wartosci dla kazdego n:
if [ -f srednieA.dat ]; then
    rm srednieA.dat
fi
if [ -f srednieB.dat ]; then
    rm srednieB.dat
fi

awk -F";" '{
    n=$1
    L+=$2
    n_ile+=1
    if (n!=n_poprzednie) {
        if (n_poprzednie!=0) {
            print n_poprzednie";"L/n_ile
        }
        n_poprzednie=n
        L=0
        n_ile=0
    }
}' wynikiA.dat | sort -n > srednieA.dat

awk -F";" '{
    n=$1
    L+=$2
    n_ile+=1
    if (n!=n_poprzednie) {
        if (n_poprzednie!=0) {
            print n_poprzednie";"L/n_ile
        }
        n_poprzednie=n
        L=0
        n_ile=0
    }
    n_poprzednie=n
} END {
    if (n_poprzednie!=0) {
    print n_poprzednie";"L/n_ile
    }
}' wynikiB.dat | sort -n > srednieB.dat

#przygotuj plik z danymi do wykresu
if [ -f ratios.dat ]; then
    rm ratios.dat
fi

#policz stosunek srednich wartosci dla kazdego n
#zapisz do pliku ratios.dat w formacie n;ln1;ln2
#ln1=LnA/f1(n)
#ln2=LnB/f2(n)
#f1(n)=log(n)/log(log(n))
#f2(n)=log(log(n))/log(2)

#otworz pliki z srednimi wartosciami
exec 3< srednieA.dat
exec 4< srednieB.dat
for n in $wartosci_n; do
    #liczby sa oddzielone srednikami n;Ln
    read -u 3 lineA
    read -u 4 lineB
    lA=$(echo $lineA | cut -d";" -f2)
    lB=$(echo $lineB | cut -d";" -f2)
    f1=$(echo "l($n)/l(l($n))" | bc -l)
    f2=$(echo "l(l($n))/l(2)" | bc -l)
    lAr=$(echo "$lA/$f1" | bc -l)
    lBr=$(echo "$lB/$f2" | bc -l)
    echo "$n;$lA;$f1;$lAr;$lB;$f2;$lBr" >> ratios.dat
done
exec 3>&-
exec 4>&-

#narysuj wykresy
plotuj "LnA" 2 "A"
plotuj "LnB" 2 "B"

plotujPotrojony "Ln1" 2 "f1" 3 "Ln1OVERf1" 4
plotujPotrojony "Ln2" 5 "f2" 6 "Ln2OVERf2" 7

#przesun wykresy do katalogu wykresy

if [ ! -d wykresy ]; then
    mkdir wykresy
fi

mv *.png wykresy
