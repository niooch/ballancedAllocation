#include <iostream>
#include <cmath>
#include <vector>
#include <random>
#include <string>

#define K 50
void symulacja(int n, int d);
int main (int argc, char *argv[]) {
    /**************
    * co bedziie podane?
    * m - ile kul -- tak naprawde nie jest uzywane
    * n - ile urn
    * d - ile urn losujemy do wyboru
    * f:[m]->[n]
    **************/
    // sprawdzanie czy podano odpowiednia ilosc argumentow
    if (argc != 3) {
        std::cout << "uzycie: ./main <n> <d>" << std::endl;
        return 1;
    }
    //inicjalizacja zmiennych
    int n = std::stoi(argv[1]);
    int d = std::stoi(argv[2]);
    //preprowadz symujacje k razy
    for(int i = 0; i < K; i++){
        symulacja(n, d);
    }
    return 0;
}
/*** NIE UZYWAC WEKTOROW BO GIGA WOLNE ***/
void symulacja(int n, int d){
    std::vector<int> urny(n, 0);

    //inicjalizacja generatora liczb losowych mersene twister
    std::random_device rd;
    std::mt19937 gen(rd());
    std::uniform_int_distribution<> losowa_urna(0, n-1);

    //inicjalizacja tablicy urn do losowania o rozmiarze d, nie wektorowej
    std::vector<int> losoweUrny;
    for(int i = 0; i < d; i++){
        losoweUrny.push_back(i);
    }

    /****************
    * co musze policzc?
    * Ln - maksymalne zapelnienie urny
    ****************/
    int counter = 0;
    while(counter <= n){
        counter++;
        //losuj urne
        for(int i = 0; i < d; i++){
            losoweUrny[i] = losowa_urna(gen);
        }
        //w ktorej urnie jest najmniej kulek
        int minIloscKulek=urny[losoweUrny[0]];
        int minIndex = losoweUrny[0];
        for(int i = 1; i < d; i++){
            if(urny[losoweUrny[i]] < minIloscKulek){
                minIloscKulek = urny[losoweUrny[i]];
                minIndex = losoweUrny[i];
            }
        }
        //dodaj kule do urny
        urny[minIndex]++;
    }
    //znajdz ile jest najwiecej kulek
    int max = urny[0];
    for(int i = 1; i < n; i++){
        if(urny[i] > max){
            max = urny[i];
        }
    }
    //wypisz wyniki
    std::cout <<n<<";"<< max << std::endl;
}
