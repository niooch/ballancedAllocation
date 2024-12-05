# Ballanced Allocation
![Zbalansowana alokacja](https://jkogut.pl/assets/ballanced.jpg)

# Problem
Jak wygląda rozłożenie kul wrzucanych do urn?
Dane mamy n kul oraz n urn. Kule wrzucamy do urn losowo z pewną modyfikacją:
* Wybieramy losowo d urn
* Wrzucamy kulę do urny z najmniejszą liczbą kul
Ile maksymalnie kul będzie znajdowało się w jednej z urn?

# Jak to działa?
Odpalamy skrypt, który wszystko ogarnia:
```bash
bash run.sh $(seq 1000 1000 1000000)
```
policzy dla `n = 1000, 2000, ..., 1000000`, opowiedniego `d = 1, 2` i zapisze wyniki, policzy średnie i narysuje wykresy.

# Co potrzebne?
* gcc
* gnuplot
* bash
* make

# Sprawozdanie
Sprawozdanie znajduje się w pliku [sprawozdanie.pdf](sprawozdanie.pdf)
