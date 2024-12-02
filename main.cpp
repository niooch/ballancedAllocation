#include <iostream>
#include <cmath>
#include <vector>
#include <random>
#include <string>

#define K 50
void symulacja(int n);
int main (int argc, char *argv[]) {
    /**************
    * co bedziie podane?
    * m - ile kul -- tak naprawde nie jest uzywane
    * n - ile urn
    * f:[m]->[n]
    **************/
    // sprawdzanie czy podano odpowiednia ilosc argumentow
    if (argc != 2) {
        std::cout << "uzycie: ./main <n>" << std::endl;
        return 1;
    }
    //inicjalizacja zmiennych
    int n = std::stoi(argv[1]);
    //preprowadz symujacje k razy
    for(int i = 0; i < K; i++){
        symulacja(n);
    }
    return 0;
}

void symulacja(int n){
    std::vector<int> urny(n, 0);

    //inicjalizacja generatora liczb losowych mersene twister
    std::random_device rd;
    std::mt19937 gen(rd());
    std::uniform_int_distribution<> losowa_urna(0, n-1);

    /****************
    * co musze policzc?
    * Bn - moment pierwszej kolizji
    * Un - ilosc pustych urn po wrzuceniu n kul
    * Cn - moment w ktorym kazda urna ma przynajmniej jedna kule (cupon colelctor problem)
    * Dn - moment w ktorym kazda urna ma przynajmniej dwie kule (warunek koncowy)
    * przy okazji Dn - Cn
    ****************/
    int counter = 0; //liczy na ktorej kulce jestesmy
    int DnCounter = 0; //liczy w ilu urnach jest przynajmniej 2 kulki
    int Bn=0; //moment pierwszej kolizji
    int Cn=0; //moment w ktorym kazda urna ma przynajmniej jedna kule
    int CnCounter = 0; //liczy w ilu urnach jest przynajmniej 1 kulka
    int Un = 0; //ilosc pustych urn po wrzuceniu n kul
    int UnCounter = n; //liczy ile jest pustych urn

    while(DnCounter < n){
        counter++;
        //losuj urne
        int urna = losowa_urna(gen);
        //wrzuc kulke
        urny[urna]++;
        //jesli w urnie jest 2 kulki to zwieksz licznik
        if(urny[urna] == 2){
            DnCounter++;
            //jesli to pierwsza kolizja to zapisz moment
            if(DnCounter == 1){
                Bn = counter;
            }
        }
        //jesli w urnie jest 1 kulka to zwieksz licznik
        if(urny[urna] == 1){
            CnCounter++;
            //jesli to pierwsza kulka w urnie to zmniejsz licznik pustych urn
            UnCounter--;
            //jesli kazda urna ma przynajmniej jedna kulke to zapisz moment
            if(CnCounter == n){
                Cn = counter;
            }
        }
        //jesli na ntym rzucie to zapisz ilosc pustych urn
        if(counter == n){
            Un = UnCounter;
        }

    }
    //wypisz wyniki
    std::cout << n <<";"<<Bn<<";"<<Un<<";"<<Cn<<";"<<counter<<";"<<counter-Cn<<std::endl;
}
