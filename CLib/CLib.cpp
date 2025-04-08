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
// Rok/Semestr: 2024/25, semestr 5, Jêzyki Asemblerowe
//
// Temat: Dodawanie szumu gausowaskiego do obrazu 
// Opis algorytmu : Dodawanie szumu do obrazu z wykorzystaniem transformaci Box - Mullera.
// Generowane s¹ dwie liczby z zakresu(0, 1), które nasepnie przekszta³cane
// s¹ zgodnie ze wzorami z transformacji.
// Zgodnie z wyborem u¿ytkownika kolor obrazu mo¿e zostaæ zamieniony tak¿e na skalê szaroœci.
//
// Wersja: 1.0
//
////////////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////////////////
// Grayscale Conversion - funckja zamieniaj¹ca kolory na skalê szaroœci w obrazie wejœciowym
// Po wykonaniu funkcji, piksele obrazu wejœciowego maj¹ przypisan¹ now¹ wartoœæ "gray",
// która jest sk³adow¹ kana³ów RGB pomno¿onych przez odpowiednie wagi kolorystyczne.
// 
// Zmienne:
// input - obraz wejœciowy
// width - szerokoœæ obrazu
// height - wysokoœæ obrazu
// startCol - poc¿atkowa kolumna [w przypadku wiekow¹tkowoœci obraz jest dzielony "pionowo"]
// endCol - koñcowa kolumna [jak wy¿ej, przy wielow¹tkowoœci]
//////////////////////////////////////////////////////////////////////////////////////////////


void Grayscale_Conversion(unsigned char* input, int width, int height, int startCol, int endCol) {
    for (int x = startCol; x < endCol; ++x) {              // pêtla "w wierszu"
        for (int y = 0; y < height; ++y) {                  // pêtla "w kolumnie"
            int index = (y * width + x) * 4;              // Indeks w tablicy ARGB
            unsigned char gray = static_cast<unsigned char>(      // nowa "szara" wartoœæ piksela
                0.299 * input[index + 2] +  // R
                0.587 * input[index + 1] + // G
                0.114 * input[index]       // B
                );

            input[index+2] = gray; // Zapisz odcieñ szaroœci do kana³u R
            input[index+1] = gray; // Zapisz odcieñ szaroœci do kana³u G
            input[index] = gray;  // Zapisz odcieñ szaroœci do kana³u B
        }
    }
}


////////////////////////////////////////////////////////////////////////////////////////////
// GenerateGaussianNoise - funkcja generuj¹ca wartoœci szumu.
// Po wykonaniu funkcji mamy wygenerowane 2 wartoœci zgodne z rozk³adem normalnym.
// Bêd¹ one potem przypisywane poszczególnym pikselom w obrazie, tak aby stworzyæ efekt szumu.
// Funkcja zaczyna siê od wylosowania 2 liczb o rozk³adzie jednostajnym z przedzia³u (0,1), 
// po czym s¹ one poddawane transformacji Box-Mullera.
// Aby zachowaæ spójnoœæ z kodem asemblerowym, transformacja jest przeprowadzana krok-po-kroku, 
// zgodnie z operacjami, jakie s¹ przeprowadzane w bibliotece asemblerowej.
// W miarê mo¿liwoœci nie u¿ywa siê tutaj wbudowanych funckji jêzyka c++.
// 
// Zmienne:
// flag - flaga wylosowania drugiej wartoœci. Jeœli jest ustawiona na 1, losowanie nie odbywa
// siê, a zapasowa wartoœæ jest u¿ywana w dalszej logice programu.
// 
//////////////////////////////////////////////////////////////////////////////////////////////

inline float GenerateGaussianNoise(int& flag) {
    static double cos_val = 0.0;                        // zmienna cosinus
    static std::random_device rd;                       // maszyna losuj¹ca
    static std::mt19937 gen(rd());                      // generator
    static std::uniform_real_distribution<> dis(0.0, 1.0); // wywo³anie rng z przedzia³u (0,1) z rozk³adem normalnym

    float result;                                       // wynik - zwracany na koniec funkcji

    if (flag == 0) {                                    // instrukcja warunkowa, flaga = 0 - nie mamy dostêpnej wolnej wartoœci
        while (true) {                                  // przeprowadzamy losowanie a¿ do uzyskania wyniku
            // Generowanie wartoœci                 
            double random_number1 = dis(gen);           // losujemy 1sza wartoœc z przedzia³u (0,1)
            double random_number2 = dis(gen);           // losujemy 2g¹ wartoœc z przedzia³u (0,1) 
            double sum = (random_number1 * random_number1) + (random_number2 * random_number2);  // liczymy sumê kwadratów wygenerowanych liczb

            if (sqrt(sum) >= 1) {                           // sprawdzamy warunek sumy S<1
                continue;                                   // Jesli suma wiêksza lub równa 1, ponawiamy losowanie
            }
            else {                                          // Suma < 1 - mo¿emy kontynuuowaæ obliczenia
                //  transformacja Box-Mullera 
                double value1 = -2 * std::log(random_number1);      // liczymy -2ln(X1)
                value1 = sqrt(value1);                              // sqrt(-2 ln(X1))
                double value2 = 2 * 3.14159265 * random_number2;    // 2piX2

                double sin_val = sin(value2);                       // wartoœæ sin(2*pi*X2)
                cos_val = cos(value2);                              // wartoœæ cos(2*pi*X2)

                sin_val = sin_val * value1;                         // zgodnie ze wzorem, to nasze Z1
                cos_val = cos_val * value1;                         // zgodnie ze wzorem, to nasze Z2
                result = static_cast<float>(sin_val);               // zapisz Z1 w zmiennej result
            }

            flag = 1;                                               // Ustawaienie flagi na 1, mamy wygenerowan¹ drug¹ wartoœæ                    
            return result;                                          // zwróæ zmienn¹ Z1
        }
    }

    result = static_cast<float>(cos_val);                           // mieliœmy drug¹ wartoœæ, zapisz Z2 pod zmienn¹ result
    flag = 0;                                                       // reset flagi, flag = 0
    return result;                                                  // Zwróæ zmeinn¹ Z2
}

////////////////////////////////////////////////////////////////////////////////////////////
// AddGaussianNoise - funkcja dodaj¹ca wartoœci szumu do obrazu wejœciowego.
// Funkcja przechodzi przez ka¿dy piksel obrazu, dla którego generowana jest wartoœæ szumu 
// zgodna z rozk³adem normalnym. W tym celu wywo³ywana jest metoda GenerateGaussianNoise,
// która wykorzytuje transformacjê Box-Mullera do uzyskania odpowiednich wartoœci.
// 
// Zmienne:
// data - obraz wejœciowy
// width - szerokoœæ obrazu
// height - wysokoœæ obrazu
// startCol - poc¿atkowa kolumna [w przypadku wiekow¹tkowoœci obraz jest dzielony "pionowo"]
// endCol - koñcowa kolumna [jak wy¿ej, przy wielow¹tkowoœci]
// val - wartoœæ odchylenia standardowego szumu, wybierana przez u¿ytkownika za pomoc¹ suwaka
// 
//////////////////////////////////////////////////////////////////////////////////////////////
void AddGaussianNoise(unsigned char* data, int width, int height, int startCol, int endCol, float val) {
    
    float noiseStdDev = val;                                    // odchylenie standardowe
    int flag = 0;                                               // flaga przekazywana do metody GenerateGaussianNoise
    for (int x = startCol; x < endCol; ++x) {                   // pêtla "w rzêdzie"
        for (int y = 0; y < height; ++y) {                      // pêtla "w kolumnie"
            int index = (y * width + x) * 4;                    // indeks ARGB

            float noise = GenerateGaussianNoise(flag) * noiseStdDev;  //Wywo³anie funkcji generuj¹cej wartoœci szumu, pomno¿enie wartoœci przez odchylenie standardowe
           
            int newValue;                                             // Zmienna newValue do przechowywania nowej wartoœci kana³u piksela

            for (int i = 0; i<3; i++){                                      //pêtla dodaj¹ca szum do ka¿dego z trzech kana³ów RGB
                newValue = static_cast<int>(data[index + i] + noise);                   // dodanie szumu do kana³u
                newValue = (newValue < 0) ? 0 : (newValue > 255) ? 255 : newValue;      //jeœli wartoœæ wykracza poza zakres [0-255], to dajemy wartoœæ skrajn¹
                data[index + i] = newValue;                                             // przypisanie nowej wartoœci do kana³u
            }

        }
    }
}


////////////////////////////////////////////////////////////////////////////////////////////
// Grayscale_ConversionCpp - funkcja eksportowana dla C#, zamieniaj¹ca wartoœæ kolorystyczn¹
//  obrazu na grayscale.
// W funkcji zachodzi podzia³ na w¹tki, gdzie w ka¿dym w¹tku wywwo³ywana jest funkcja
//  Crayscale_Conversion zmieniaj¹ca kolor obrazu na skalê szaroœci.
//
// Zmienne:
// data - obraz wejœciowy
// width - szerokoœæ obrazu
// height - wysokoœæ obrazu
// numThreads - liczba w¹tków w programie
// 
//////////////////////////////////////////////////////////////////////////////////////////////
extern "C" __declspec(dllexport) void __stdcall Grayscale_ConversionCpp(unsigned char* data, int width, int height, int numThreads) {
 
    std::vector<std::thread> threads;                   //wektor w¹tków
    int colsPerThread = width / numThreads;             // iloœæ kolumn w w¹tku, obraz jest dzielony "pionowo"

    for (int i = 0; i < numThreads; ++i) {              // pêtla podzia³u na w¹tki
        int startCol = i * colsPerThread;               // obliczanie pocz¹tkowej kolumny obrazu w w¹tku
        int endCol = (i == numThreads - 1) ? width : (i + 1) * colsPerThread;               // obliczne koñcowej kolumny obrazu w w¹tku
        threads.emplace_back(Grayscale_Conversion, data, width, height, startCol, endCol);  // dodaniw w¹tku do wektora w¹tków z funckj¹ Grayscale_Conversion jako parametr
    }

    for (auto& thread : threads) {      // dla ka¿dego w¹tku w wektorze
        thread.join();                  // wykonanie w¹tku
    }

    threads.clear();                    // wyczyszczenie wektora
}

////////////////////////////////////////////////////////////////////////////////////////////
// AddGaussianNoiseCpp - funkcja eksportowana dla C#, dodaj¹ca szum gausowski do obrazu.
// 
// W funkcji zachodzi podzia³ na w¹tki, gdzie w ka¿dym w¹tku wywwo³ywana jest funkcja
//  AddGaussianNoise dodaj¹ca szum gaussowski do obrazu.
//
// Zmienne:
// data - obraz wejœciowy
// width - szerokoœæ obrazu
// height - wysokoœæ obrazu
// numThreads - liczba w¹tków w programie
// val - odchylenie standardowe szumu, wybierane przez u¿ytkownika za pomoc¹ suwaka
// 
//////////////////////////////////////////////////////////////////////////////////////////////
extern "C" __declspec(dllexport) void __stdcall AddGaussianNoiseCpp(unsigned char* data, int width, int height, int numThreads, float val) {

    std::vector<std::thread> threads;                   //wektor w¹tków
    int colsPerThread = width / numThreads;             // iloœæ kolumn w w¹tku, obraz jest dzielony "pionowo"
    float value = val;                                  // zmienna przechowuj¹ca odchylenie standardowe

    for (int i = 0; i < numThreads; ++i) {              // pêtla podzia³u na w¹tki
        int startCol = i * colsPerThread;                // obliczanie pocz¹tkowej kolumny obrazu w w¹tku
        int endCol = (i == numThreads - 1) ? width : (i + 1) * colsPerThread;                       // obliczne koñcowej kolumny obrazu w w¹tku
        threads.emplace_back(AddGaussianNoise, data, width, height, startCol, endCol, value);       // dodaniw w¹tku do wektora w¹tków z funckj¹ AddGaussianNoise jako parametr
    }

    for (auto& thread : threads) {       // dla ka¿dego w¹tku w wektorze
        thread.join();                  // wykonanie w¹tku
    }

    threads.clear();                    // wyczyszczenie wektora

}