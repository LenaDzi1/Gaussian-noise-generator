#include "pch.h"
#include "framework.h"
#include "CLib.h"
#include <thread>
#include <vector>
#include <windows.h>
#include <iostream>
#include <random>
#include <algorithm>

/////////////////////////////////////////////////////////////////////////////////////////////
// Autor: Lena Dziurska
// 
// Rok/Semestr: 2024/25, semestr 5, J�zyki Asemblerowe
//
// Temat: Dodawanie szumu gausowaskiego do obrazu 
// Opis algorytmu : Dodawanie szumu do obrazu z wykorzystaniem transformaci Box - Mullera.
// Generowane s� dwie liczby z zakresu(0, 1), kt�re nasepnie przekszta�cane
// s� zgodnie ze wzorami z transformacji.
// Zgodnie z wyborem u�ytkownika kolor obrazu mo�e zosta� zamieniony tak�e na skal� szaro�ci.
//
// Wersja: 1.0
//
////////////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////////////////
// Grayscale Conversion - funckja zamieniaj�ca kolory na skal� szaro�ci w obrazie wej�ciowym
// Po wykonaniu funkcji, piksele obrazu wej�ciowego maj� przypisan� now� warto�� "gray",
// kt�ra jest sk�adow� kana��w RGB pomno�onych przez odpowiednie wagi kolorystyczne.
// 
// Zmienne:
// input - obraz wej�ciowy
// width - szeroko�� obrazu
// height - wysoko�� obrazu
// startCol - poc�atkowa kolumna [w przypadku wiekow�tkowo�ci obraz jest dzielony "pionowo"]
// endCol - ko�cowa kolumna [jak wy�ej, przy wielow�tkowo�ci]
//////////////////////////////////////////////////////////////////////////////////////////////


void Grayscale_Conversion(unsigned char* input, int width, int height, int startCol, int endCol) {
    for (int x = startCol; x < endCol; ++x) {              // p�tla "w wierszu"
        for (int y = 0; y < height; ++y) {                  // p�tla "w kolumnie"
            int index = (y * width + x) * 4;              // Indeks w tablicy ARGB
            unsigned char gray = static_cast<unsigned char>(      // nowa "szara" warto�� piksela
                0.299 * input[index + 2] +  // R
                0.587 * input[index + 1] + // G
                0.114 * input[index]       // B
                );

            input[index+2] = gray; // Zapisz odcie� szaro�ci do kana�u R
            input[index+1] = gray; // Zapisz odcie� szaro�ci do kana�u G
            input[index] = gray;  // Zapisz odcie� szaro�ci do kana�u B
        }
    }
}


////////////////////////////////////////////////////////////////////////////////////////////
// GenerateGaussianNoise - funkcja generuj�ca warto�ci szumu.
// Po wykonaniu funkcji mamy wygenerowane 2 warto�ci zgodne z rozk�adem normalnym.
// B�d� one potem przypisywane poszczeg�lnym pikselom w obrazie, tak aby stworzy� efekt szumu.
// Funkcja zaczyna si� od wylosowania 2 liczb o rozk�adzie jednostajnym z przedzia�u (0,1), 
// po czym s� one poddawane transformacji Box-Mullera.
// Aby zachowa� sp�jno�� z kodem asemblerowym, transformacja jest przeprowadzana krok-po-kroku, 
// zgodnie z operacjami, jakie s� przeprowadzane w bibliotece asemblerowej.
// W miar� mo�liwo�ci nie u�ywa si� tutaj wbudowanych funckji j�zyka c++.
// 
// Zmienne:
// flag - flaga wylosowania drugiej warto�ci. Je�li jest ustawiona na 1, losowanie nie odbywa
// si�, a zapasowa warto�� jest u�ywana w dalszej logice programu.
// 
//////////////////////////////////////////////////////////////////////////////////////////////

inline float GenerateGaussianNoise(int& flag) {
    static double cos_val = 0.0;                        // zmienna cosinus
    static std::random_device rd;                       // maszyna losuj�ca
    static std::mt19937 gen(rd());                      // generator
    static std::uniform_real_distribution<> dis(0.0, 1.0); // wywo�anie rng z przedzia�u (0,1) z rozk�adem normalnym

    float result;                                       // wynik - zwracany na koniec funkcji

    if (flag == 0) {                                    // instrukcja warunkowa, flaga = 0 - nie mamy dost�pnej wolnej warto�ci
        while (true) {                                  // przeprowadzamy losowanie a� do uzyskania wyniku
            // Generowanie warto�ci                 
            double random_number1 = dis(gen);           // losujemy 1sza warto�c z przedzia�u (0,1)
            double random_number2 = dis(gen);           // losujemy 2g� warto�c z przedzia�u (0,1) 
            double sum = (random_number1 * random_number1) + (random_number2 * random_number2);  // liczymy sum� kwadrat�w wygenerowanych liczb

            if (sqrt(sum) >= 1) {                           // sprawdzamy warunek sumy S<1
                continue;                                   // Jesli suma wi�ksza lub r�wna 1, ponawiamy losowanie
            }
            else {                                          // Suma < 1 - mo�emy kontynuuowa� obliczenia
                //  transformacja Box-Mullera 
                double value1 = -2 * std::log(random_number1);      // liczymy -2ln(X1)
                value1 = sqrt(value1);                              // sqrt(-2 ln(X1))
                double value2 = 2 * 3.14159265 * random_number2;    // 2piX2

                double sin_val = sin(value2);                       // warto�� sin(2*pi*X2)
                cos_val = cos(value2);                              // warto�� cos(2*pi*X2)

                sin_val = sin_val * value1;                         // zgodnie ze wzorem, to nasze Z1
                cos_val = cos_val * value1;                         // zgodnie ze wzorem, to nasze Z2
                result = static_cast<float>(sin_val);               // zapisz Z1 w zmiennej result
            }

            flag = 1;                                               // Ustawaienie flagi na 1, mamy wygenerowan� drug� warto��                    
            return result;                                          // zwr�� zmienn� Z1
        }
    }

    result = static_cast<float>(cos_val);                           // mieli�my drug� warto��, zapisz Z2 pod zmienn� result
    flag = 0;                                                       // reset flagi, flag = 0
    return result;                                                  // Zwr�� zmeinn� Z2
}

////////////////////////////////////////////////////////////////////////////////////////////
// AddGaussianNoise - funkcja dodaj�ca warto�ci szumu do obrazu wej�ciowego.
// Funkcja przechodzi przez ka�dy piksel obrazu, dla kt�rego generowana jest warto�� szumu 
// zgodna z rozk�adem normalnym. W tym celu wywo�ywana jest metoda GenerateGaussianNoise,
// kt�ra wykorzytuje transformacj� Box-Mullera do uzyskania odpowiednich warto�ci.
// 
// Zmienne:
// data - obraz wej�ciowy
// width - szeroko�� obrazu
// height - wysoko�� obrazu
// startCol - poc�atkowa kolumna [w przypadku wiekow�tkowo�ci obraz jest dzielony "pionowo"]
// endCol - ko�cowa kolumna [jak wy�ej, przy wielow�tkowo�ci]
// val - warto�� odchylenia standardowego szumu, wybierana przez u�ytkownika za pomoc� suwaka
// 
//////////////////////////////////////////////////////////////////////////////////////////////
void AddGaussianNoise(unsigned char* data, int width, int height, int startCol, int endCol, float val) {
    
    float noiseStdDev = val;                                    // odchylenie standardowe
    int flag = 0;                                               // flaga przekazywana do metody GenerateGaussianNoise
    for (int x = startCol; x < endCol; ++x) {                   // p�tla "w rz�dzie"
        for (int y = 0; y < height; ++y) {                      // p�tla "w kolumnie"
            int index = (y * width + x) * 4;                    // indeks ARGB

            float noise = GenerateGaussianNoise(flag) * noiseStdDev;  //Wywo�anie funkcji generuj�cej warto�ci szumu, pomno�enie warto�ci przez odchylenie standardowe
           
            int newValue;                                             // Zmienna newValue do przechowywania nowej warto�ci kana�u piksela

            for (int i = 0; i<3; i++){                                      //p�tla dodaj�ca szum do ka�dego z trzech kana��w RGB
                newValue = static_cast<int>(data[index + i] + noise);                   // dodanie szumu do kana�u
                newValue = (newValue < 0) ? 0 : (newValue > 255) ? 255 : newValue;      //je�li warto�� wykracza poza zakres [0-255], to dajemy warto�� skrajn�
                data[index + i] = newValue;                                             // przypisanie nowej warto�ci do kana�u
            }

        }
    }
}


////////////////////////////////////////////////////////////////////////////////////////////
// Grayscale_ConversionCpp - funkcja eksportowana dla C#, zamieniaj�ca warto�� kolorystyczn�
//  obrazu na grayscale.
// W funkcji zachodzi podzia� na w�tki, gdzie w ka�dym w�tku wywwo�ywana jest funkcja
//  Crayscale_Conversion zmieniaj�ca kolor obrazu na skal� szaro�ci.
//
// Zmienne:
// data - obraz wej�ciowy
// width - szeroko�� obrazu
// height - wysoko�� obrazu
// numThreads - liczba w�tk�w w programie
// 
//////////////////////////////////////////////////////////////////////////////////////////////
extern "C" __declspec(dllexport) void __stdcall Grayscale_ConversionCpp(unsigned char* data, int width, int height, int numThreads) {
 
    std::vector<std::thread> threads;                   //wektor w�tk�w
    int colsPerThread = width / numThreads;             // ilo�� kolumn w w�tku, obraz jest dzielony "pionowo"

    for (int i = 0; i < numThreads; ++i) {              // p�tla podzia�u na w�tki
        int startCol = i * colsPerThread;               // obliczanie pocz�tkowej kolumny obrazu w w�tku
        int endCol = (i == numThreads - 1) ? width : (i + 1) * colsPerThread;               // obliczne ko�cowej kolumny obrazu w w�tku
        threads.emplace_back(Grayscale_Conversion, data, width, height, startCol, endCol);  // dodaniw w�tku do wektora w�tk�w z funckj� Grayscale_Conversion jako parametr
    }

    for (auto& thread : threads) {      // dla ka�dego w�tku w wektorze
        thread.join();                  // wykonanie w�tku
    }

    threads.clear();                    // wyczyszczenie wektora
}

////////////////////////////////////////////////////////////////////////////////////////////
// AddGaussianNoiseCpp - funkcja eksportowana dla C#, dodaj�ca szum gausowski do obrazu.
// 
// W funkcji zachodzi podzia� na w�tki, gdzie w ka�dym w�tku wywwo�ywana jest funkcja
//  AddGaussianNoise dodaj�ca szum gaussowski do obrazu.
//
// Zmienne:
// data - obraz wej�ciowy
// width - szeroko�� obrazu
// height - wysoko�� obrazu
// numThreads - liczba w�tk�w w programie
// val - odchylenie standardowe szumu, wybierane przez u�ytkownika za pomoc� suwaka
// 
//////////////////////////////////////////////////////////////////////////////////////////////
extern "C" __declspec(dllexport) void __stdcall AddGaussianNoiseCpp(unsigned char* data, int width, int height, int numThreads, float val) {

    std::vector<std::thread> threads;                   //wektor w�tk�w
    int colsPerThread = width / numThreads;             // ilo�� kolumn w w�tku, obraz jest dzielony "pionowo"
    float value = val;                                  // zmienna przechowuj�ca odchylenie standardowe

    for (int i = 0; i < numThreads; ++i) {              // p�tla podzia�u na w�tki
        int startCol = i * colsPerThread;                // obliczanie pocz�tkowej kolumny obrazu w w�tku
        int endCol = (i == numThreads - 1) ? width : (i + 1) * colsPerThread;                       // obliczne ko�cowej kolumny obrazu w w�tku
        threads.emplace_back(AddGaussianNoise, data, width, height, startCol, endCol, value);       // dodaniw w�tku do wektora w�tk�w z funckj� AddGaussianNoise jako parametr
    }

    for (auto& thread : threads) {       // dla ka�dego w�tku w wektorze
        thread.join();                  // wykonanie w�tku
    }

    threads.clear();                    // wyczyszczenie wektora

}