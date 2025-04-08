; AsmLib.asm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Autor: Lena Dziurska
; Rok/semestr: 2024/25, semestr 5, Jêzyki Asemblerowe
;
; Temat: Dodawanie szumu gausowaskiego do obrazu 
; Opis algorytmu: Dodawanie szumu do obrazu z wykorzystaniem transformaci Box-Mullera.
; Generowane s¹ dwie liczby z zakresu (0,1), które nasepnie przekszta³cane 
; s¹ zgodnie ze wzorami z transformacji.
; Zgodnie z wyborem u¿ytkownika kolor obrazu mo¿e zostaæ zamieniony tak¿e na skalê szaroœci.
; 
; Wersja: 1.0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


.data
;;;;;;;;;;; STA£E I DANE W ASM: ;;;;;;;;;;;;;;;;;;;;;;

    two_to_64 REAL8 1.0842021724855044E-19  ; 2^(-64) w formacie zmiennoprzecinkowym (REAL8)

    zero        dq 0.0 
    one         dq 1.0    
    two         dq 2.0
    three       dq 3.0
    neg_one     dq -1.0    
    neg_two     dq -2.0     
    pi          dq  3.14159

    red         dq 0.299        ; waga dla kana³u R
    green       dq 0.587        ; waga dla kana³u G
    blue        dq 0.114        ; waga dla kana³u B
  
    result REAL8 0.0  ; To store the result  
    value  QWORD 1.0  ; Example value (use whatever is in RAX)



.code

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; FUNKCJA ZMIENIAJ¥CA OBRAZ NA SKALÊ SZAROŒCI ;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Grayscale_Conversion PROC
    ;Procedura zamiany bitmapy na odcienie szaroœci z wykorzytsaniem wag kana³ów RBG [odcienie szaroœci dla ludzkiego oka]

    ; Przekazane zmienne:
    ; rcx - wskaŸnik na pierwszy pixel bitmapy (unsigned char)
    ; rdx - szerokoœæ
    ; r8  - wysokoœæ min
    ; r9  - wysokoœæ max

    ; Inne zmienne:
    ; r15 - licznik wysokoœci
    ; r14 - sta³a szerokoœæx4
    ; r13 - licznik pikseli w wierszu
    ; r12 - wskaŸnik na piksel w pierwszej kolumnie
    ; r11 - wskaŸnik na piksel w wierszu



    xor r15, r15             ; r15 - licznik wysokoœci; bêdzie porównywany z wysokoœæ_max [r9] aby zakoñczyæ procedurê
    mov r15, r8              ; inicjalizujemy licznik wysokoœci [r15] wysokoœci¹ min [r8]
    
    mov r14, rdx             ; przenosimy szerokoœæ obrazu do rejestru r14
    imul r14, 4              ;rejestr r14 mno¿ymy x4 - r14 to szerokoœæ z uzglêdnieniem RGBA

loop_column_segment:
    cmp r15, r9              ; Porównanie licznika wysokoœci z wysokoœæ_max
    jge end_process          ; jesli koniec obrazu, koñczymy proces

    xor r13, r13             ; r13 = 0, licznik pikseli w wierszu

    mov r12, r15             ; r12 = licznik wysokoœci
    imul r12, r14            ; mno¿ymy przez szerokoœæ RGBA [x4] - u nas sta³a w r14
    add r12, rcx             ; dodajemy wskaŸnik do pierwszego piksela - r12 = wskaŸnik na pierwszy piksel

loop_in_a_row:
    cmp r13, rdx             ; porównujemy piksele w wierszu z jego szerokoœci¹
    jge end_row              ; Dotarliœmy do koñca wiersza, koñczymy pêtlê

    mov r11, r13             ; r13 = licznik pikseli w wierszu
    imul r11, r11, 4         ; mno¿ymy x4 [jakby "szerokoœæ piksela"] z uwagi na RGBA
    add r11, r12             ; Dodajemy wskaŸnik pierwszego piksela [r12] - r11 = wskaŸnik pikseli w wierszu


    ;//////////// Dla kana³u R ///////////////
    movzx ebx, byte ptr [r11+2]        ; Wczytujemy kana³ R do ebx
    movd xmm0, ebx                     ; Przenosimy go do rejestru zmeinnoprzecinkowego xmm0
    movsd xmm1, [red]                  ; Do rejestru xmm1 wstawiamy wagê czerwieni [Red]
    mulsd xmm0, xmm1                   ; mno¿ymy obecn¹ wartoœæ kana³u przez wagê
    movd ebx, xmm0                     ; wynik z powrotem w ebx
    mov eax, ebx                       ; przenosimy t¹ wartoœæ do eax [akumulator]

    ;//////////// Dla kana³u G ///////////////
    movzx ebx, byte ptr [r11+1]      ; Wczytujemy kana³ G do ebx
    movd xmm0, ebx                   ; Przenosimy go do rejestru zmeinnoprzecinkowego xmm0
    movsd xmm1, [green]              ; Do rejestru xmm1 wstawiamy wagê zieleni [Green]
    mulsd xmm0, xmm1                 ; mno¿ymy obecn¹ wartoœæ kana³u przez wagê
    movd ebx, xmm0                   ; wynik z powrotem w ebx
    add eax, ebx                     ; dodajemy t¹ wartoœæ do akumulatora [R+G]

    ;//////////// Dla kana³u B ///////////////
    movzx ebx, byte ptr [r11]        ; Wczytujemy kana³ B do ebx
    movd xmm0, ebx                   ; Przenosimy go do rejestru zmeinnoprzecinkowego xmm0
    movsd xmm1, [blue]               ; Do rejestru xmm1 wstawiamy wagê b³êkitu [Blue]
    mulsd xmm0, xmm1                 ; mno¿ymy obecn¹ wartoœæ kana³u przez wagê
    movd ebx, xmm0                   ; wynik z powrotem w ebx
    add eax, ebx                     ; dodajemy t¹ wartoœæ do akumulatora [R+G+B]

    mov byte ptr [r11+2], al         ; Przenosimy wartoœæ do kana³u R
    mov byte ptr [r11+1], al         ; Przenosimy wartoœæ do kana³u G
    mov byte ptr [r11], al           ; Przenosimy wartoœæ do kana³u B


    inc r13                    ; Zwiêkszamy licznik pikseli w wierszu
    jmp loop_in_a_row          ; Przechodzimy do kolejnego piksela w danym wierszu

end_row:
    inc r15                    ; Zwiêkszamy licznik wysokoœci
    jmp loop_column_segment    ; Przechodzimy do kolejnego wiersza

end_process:
    ret                         ; powrót z procedury
Grayscale_Conversion ENDP




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; FUNKCJA DODAJ¥CA SZUM DO OBRAZU ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

AddGaussianNoise PROC
    ; Procedura dodaj¹ca szum gaussowski do obrazu. Wykorzystuje metodê Box-Mullera.
    ; Wykorzystuje generowanie liczb losowych z procesora oraz 
    ; wykorzystuje szereg Maclaurina to wyliczenia ln(X1).

    ; Przekazane zmienne:
    ; rcx - wskaŸnik na pierwszy pixel bitmapy (unsigned char)
    ; rdx - szerokoœæ
    ; r8  - wysokoœæ min
    ; r9  - wysokoœæ max / iteracje Maclaurin
    ; xmm0 - odchylenie standardowe [dev]

    ; Inne zmienne:
    ; r15 - flaga przechowywania drugiej wylosowanej wartoœci [0 lub 1]
    ; r14 - sta³a szerokoœæx4
    ; r13 - licznik pikseli w wierszu / Rand2 / licznik kana³u w pikselu
    ; r12 - wskaŸnik na piksel w pierwszej kolumnie
    ; r11 - wskaŸnik na piksel w wierszu / Rand1
    ; r10 - licznik wysokoœci

    ; Zmiennoprzecinkowe:
    ; xmm1 - Rand1 / X1 / [X1-1] / [X1-1]/N  / ln(X1) / (-2 ln(X1)) / sqrt (-2 ln(X1))
    ; xmm2 - 2 ^ (-64) / 0.0 / X1^2 / S / X1-1 / sqrt (-2lnX1) / sqrt (-2lnX1) * sin / z1*dev
    ; xmm3 - Rand2 / X2 /  3.14 * X2/ 2*3.14*X2  / sqrt (-2lnX1) / sqrt (-2lnX1)* cos / z2*dev
    ; xmm4 - -1.0 / X2^2 / 1.0/ n indeks/ -2.0 / 3.14 / 2.0 / 0.0 / dev
    ; xmm5 - ln(X1) / 0.0
    ; xmm6 - 1.0 /0.0
    ; xmm7 - sin (2 3.14 x2) / 0.0
    ; xmm8 - cos (2 3.14 x2) / 0.0



    xor r10, r10             ; r10 - licznik wysokoœci; bêdzie porównywany z wysokoœæ_max [r9] aby zakoñczyæ procedurê
    mov r10, r8              ; inicjalizujemy licznik wysokoœci [r10] wysokoœci¹ min [r8]
    
    mov r14, rdx             ; przenosimy szerokoœæ obrazu do rejestru r14
    imul r14, 4              ; rejestr r14 mno¿ymy x4 - r14 to szerokoœæ z uzglêdnieniem RGBA

loop_column_segment:
    cmp r10, r9              ; Porównanie licznika wysokoœci z wysokoœæ_max
    jge end_process          ; jesli koniec obrazu, koñczymy proces

    xor r13, r13             ; r13 = 0, licznik pikseli w wierszu

    mov r12, r10             ; r12 = licznik wysokoœci
    imul r12, r14            ; mno¿ymy przez szerokoœæ RGBA [x4] - u nas sta³a w r14
    add r12, rcx             ; dodajemy wskaŸnik do pierwszego piksela - r12 = wskaŸnik na pierwszy piksel

loop_in_a_row:
    cmp r13, rdx             ; porównujemy piksele w wierszu z jego szerokoœci¹
    jge end_row              ; Dotarliœmy do koñca wiersza, koñczymy pêtlê

    mov r11, r13             ; r13 = licznik pikseli w wierszu
    imul r11, r11, 4         ; mno¿ymy x4 [jakby "szerokoœæ piksela"] z uwagi na RGBA
    add r11, r12             ; Dodajemy wskaŸnik pierwszego piksela [r12] - r11 = wskaŸnik pikseli w wierszu

    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  tu sie zaczyna logika ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 Normal_distribution:   
    cmp r15, 1               ; Sprawdzamy wyst¹pienie drugiej wartoœci - flaga r15
    je  flag_one             ; Jeœli mamy wartoœæ to jej nie generujemy - skok do "flag_one"


    ;;;;;;;;;;;;;;;;; Generowanie wartoœci losowych ;;;;;;;;;;;;;;;;;;;;;
generate_values:
    
    push r13                ; odk³adamy licznik pikseli [r13] na stos
    push r11                ; odk³adamy wskaŸnik na pixel w wierszu [r11] na stos
        
    ; Generowanie losowych wartoœci X1 i X2
    rdrand r11              ; Zapisuje losow¹ wartoœæ 64-bitow¹ do r11

    ; Przekszta³cenie liczby ca³kowitej na zmiennoprzecinkow¹ (X1)
    cvtsi2sd xmm1, r11      ; Konwertujemy 64-bitow¹ liczbê ca³kowit¹ na zmiennoprzecinkow¹ (XMM1)

    ; Dzielimy przez 2^64, aby uzyskaæ liczbê w przedziale (0, 1)
    movsd xmm2, [two_to_64]   ; Za³aduj 2^(-64) do xmm2
    mulsd xmm1, xmm2          ; Mno¿ymy XMM1 (losowa liczba) przez 2^(-64) z xmm2


; Powtarzamy dla drugiej liczby
    rdrand r13                ; Zapisuje losow¹ wartoœæ 64-bitow¹ do r13
    cvtsi2sd xmm3, r13        ; Konwertujemy 64-bitow¹ liczbê ca³kowit¹ na zmiennoprzecinkow¹ (XMM3)


    pop r11                   ; przywrócenie r13 ze stosu - ju¿ nie bedzie nam potrzebny dodatkowy rejestr
    pop r13                   ; przywrócenie r11 ze stosu - ju¿ nie bedzie nam potrzebny dodatkowy rejestr

    mulsd xmm3, xmm2          ; Mno¿ymy XMM2 (losowa liczba) przez 2^(-64) z xmm2


    movsd XMM2, [zero]        ; Wczytaj 0.0 do XMM2 (dla double)
    movsd XMM4, [neg_one]     ; Wczytaj -1.0 do XMM4 (dla double)
    comisd XMM1, XMM2         ; Porównaj XMM1 z XMM2 (XMM2 zawiera 0.0)


 
    jz generate_values      ; Jesli wygenerowana wartoœæ to 0 - powtórz losowanie
    comisd XMM1, XMM2       ; Porównaj XMM1 z XMM2 (XMM2 zawiera 0.0)
    jae positivex1          ; jeœli wartoœæ jest dodatnia, pomiñ mno¿enie -1

    mulsd xmm1, xmm4        ; negatywna wartoœæ - zamiana znaku, mno¿enie *-1.0

positivex1:
    comisd XMM3, XMM2      ; Porównaj XMM3 z XMM2 (XMM2 zawiera 0.0)
    jz generate_values     ; Jesli wygenerowana wartoœæ to 0 - powtórz losowanie
    comisd XMM3, XMM2      ; Porównaj XMM3 z XMM2 (XMM2 zawiera 0.0)
    jae positivex2         ; jeœli wartoœæ jest dodatnia, pomiñ mno¿enie -1

    mulsd xmm3, xmm4        ; negatywna wartoœæ - zamiana znaku, mno¿enie *-1.0
    
positivex2:
    movsd XMM2, XMM1        ; kopiuj X1 do xmm2
    movsd XMM4, XMM3        ; kopiuj X2 do xmm4

    mulsd XMM2, XMM2        ;do kwadratu XMM2 czyli nasze X1
    mulsd XMM4, XMM4        ;do kwadratu XMM4 czyli nasze X2

    addsd XMM2, XMM4         ; xmm2 = suma kwadratów liczb
    movsd XMM4, [one]        ; Wczytaj 1.0 do XMM3 (dla double)
    comisd XMM2, XMM4        ; porównaj sumê z 1
    jae generate_values      ; jeœli suma jest wiêksza od 1, wygeneruj nowe wartoœci

 ; Jeœli suma jest < 1, przechodzimy do dalszych obliczeñ

    ;;;;;;;;;;;;;;;;;; koniec generowania wartoœci ;;;;;;;;;;;;;;;;;;;;





    ;;;;;;;;;;;;;;;;;; obliczanie szeregu Maclaurina ln (X1) ;;;;;;;;;;;;;;;

    subsd XMM1, XMM4           ; XMM1 = X1 - 1
    movsd XMM2, XMM1           ; kopia (x1-1) w xmm2 - to bêdzie nasz mno¿nik licznika
    movsd XMM6, XMM4           ; XMM6 = 1 sk³adnik dla sumy mianownika, XMM4 = 1 nasz mianownik

    push r9                     ; od³ó¿ wysokoœæ_max [r9] na stos

    xor r9, r9                  ; r9 = 0 (licznik iteracji w rozwiniêciu szeregu)
    xorpd XMM5, XMM5            ; XMM5 = 0, czyœcimy rejestr

Loop_Macl:
    cmp r9, 100          ; Sprawdzamy, czy r9 >= 100, czy wyst¹pi³o tyle iteracji
    jge End_Macl            ; Jeœli tak, koñczymy pêtlê


    divsd xmm1, xmm4          ; xmm1 = xmm1 / xmm4 (dzielenie)
    addsd XMM5, XMM1          ; dodanie sk³adnika szeregu do zmiennej wynikowej
       
    mulsd xmm1, xmm4          ; mno¿enie by przywróciæ licznik 
    mulsd XMM1, XMM2          ; XMM1 *= XMM2 (mno¿enie przez X1-1)
    addsd XMM4, XMM6          ; Zwiêkszamy XMM4 (indeks)
    inc r9                    ; Zwiêkszamy licznik iteracji

    divsd xmm1, xmm4         ; xmm1 = xmm1 / xmm4 (dzielenie)
    subsd XMM5, XMM1         ; odjecie sk³adnika szeregu od zmienej wynikowej
  
    mulsd xmm1, xmm4         ; mno¿enie by przywróciæ licznik
    mulsd XMM1, XMM2         ; XMM1 *= XMM2 (mno¿enie przez X1-1)
    addsd XMM4, XMM6         ; Zwiêkszamy XMM4 (indeks)
    inc r9                   ; Zwiêkszamy licznik iteracji

    jmp Loop_Macl           ; Wracamy do pocz¹tku pêtli


End_Macl:

    ;;;;;;;;;;;;;;;;; koniec wyznaczania wartoœci ln(X1) szeregu Maclaurina ;;;;;;;;;;;;;;;;;;;;;;;;;;
; w XMM1 = Potêgi X1-1  ; w XMM2 = X1-1; w XMM3 = X2,  w XMM4 = liczba n*1  iteracji, w XMM5 = ln (X1), w XMM6 = 1
    
    
    
    pop r9              ; Przywracamy r9 - wys_max

    movsd XMM1, XMM5    ; przenosimy wynik ln(X1) do XMM1

    ; mno¿enie przez -2
    movsd XMM4, [neg_two]                 ; -2.0 do rejestru xmm4
    mulsd XMM1, XMM4 ; -2ln(X1) W XMM0    ; mno¿my logarytm przez -2 

    sqrtsd XMM1, XMM1                     ; pierwiastek z tego, xmm1 = sqrt (-2ln(X1))

    ;mno¿enie przez 2pi
    movsd XMM4, [pi]                      ; xmm4 = pi
    mulsd XMM3, XMM4                      ; zmm3 = X2*pi  

    movsd XMM4, [two]                     ; xmm4 = 2
    mulsd XMM3, XMM4                      ; XMM3 = 2piX2
        
    movsd qword ptr [value], xmm3     ; przenosimy wartoœæ z xmm3 do zmiennej [value]
 
    ;; liczymy sin (2piX2)
    fld [value]                       ; Za³adowanie [value] z pamieci do stostu FPU (ST(0)
       
    
    fsin                             ; teraz st(0) = sin( st(0) );
    fstp result                      ; wynik przechowywany w result [pop the FPU stack]
    movsd xmm7, [result]             ; wartoœæ z [result] zapisywana do xmm7 = sin(2piX2)


    ;; powtarzamy dla cos(2piX2)
    fld [value]                     ; Za³adowanie [value] z pamieci do stostu FPU (ST(0)v
       
    
    fcos                           ; teraz st(0) = cos( st(0) );
    fstp result                    ; wynik przechowywany w result [pop the FPU stack]
    movsd xmm8, [result]           ; wartoœæ z [result] zapisywana do xmm8 = cos(2piX2)

    movsd xmm2, xmm1                ;przenosimy sqrt(-2ln(X1)) do xmm2
    movsd xmm3, xmm1                ;przenosimy sqrt(-2ln(X1)) do xmm3

    mulsd xmm2, xmm7        ; xmm2 = Z1     sqrt(-2ln(X1)) * sin(2piX2)
    mulsd xmm3, xmm8        ; xmm3 = Z2     sqrt(-2ln(X1)) * cos(2piX2)

    ;;;;;;;;; wyczyœciæ xmm 4, 5, 6, 7, 8
    movsd xmm4, [zero]
    movsd xmm5, [zero]
    movsd xmm6, [zero]
    movsd xmm7, [zero]
    movsd xmm8, [zero]


    mov r15, 1                  ; flaga = 1, wygenerowaliœmy ju¿ 2 wartoœci, jedna jest od³o¿ona

    mulsd xmm2, xmm0            ; mno¿enie Z1 przez odchylenie standardowe
    mulsd xmm3, xmm0            ; mno¿enie Z2 przez odchylenie standardowe

    push r13                    ; od³o¿enie r13 - licznik pikseli w wierszu
	mov r13, r11                ; r13 - licznik kana³u w pikselu
	add r13, 3                  ; r13 = r11 + 3 czyli kana³ A [r11 - wska¿nik na piksel]

	
to_jest_petla:
	cvttsd2si eax, xmm2              ; Z1 w eax; ogólnie r15 = 1 czyli mamy od³ozon¹ wartoœæ z2, korzystamy z z1
_dla_r15:
    movzx ebx, byte ptr [r11]        ; Wczytaj kana³ do ebx
    add eax, ebx                     ; Dodaj wynik do eax = chanel_value + Z1
   
    cmp eax, 255                      ; porównaj z 255
    jge _value255                     ; jeœli >255 poza zakresem idz do _value255
    cmp eax, 0                        ; porównaj z 0
    jbe _value0                       ; jeœli <0 poza zakresem idŸ do _value0
    jmp next                          ; idŸ dalej

_value255:                      
    mov eax, 255                        ; wpisz 255 do akumulatora
    jmp next                            ; idŸ dalej
_value0:
    mov eax, 0                          ; wpisz 0 do akumulatora
next:
    mov byte ptr [r11], al           ; Wpisz wartoœc z akumulatora do aktualnego kana³u
	inc r11                          ; inkrementacja wska¿nika na kana³ 
	cmp r11, r13                     ; porównaj z r13, czy przeszliœmy ju¿ przez wszystkie kana³y RGB
	je continue                      ; jeœli tak, wyjdŸ z pêtli [kontynuuj]   
	cmp r15, 1                       ; sprawdŸ flagê na r15 [1 = mamy niewykorzystan¹ drug¹ wartoœæ]
	je to_jest_petla                 ; jeœli tak idŸ do pocz¹tku pêtli
    jmp zapis_xmm3                   ; jeœli zero, idŸ do przypadku z wykorzystaniem Z2
	
	
	
    jmp continue            ;wyjdŸ z pêtli [kontynuuj]

flag_one:
	mov r15, 0              ;zerowanie flagi
	push r13                ; od³o¿enie r13 - licznik pikseli w wierszu
	mov r13, r11            ; r13 - licznik kana³u w pikselu
	add r13, 3              ; r13 = r11 + 3 czyli kana³ A [r11 - wska¿nik na piksel]
	
zapis_xmm3:
	cvttsd2si eax, xmm3     ; w przypadku r15 = 0 [wykorzytujemy wartoœæ z2]
	jmp _dla_r15            ; skok do "reszty pêtli"
    

continue:
    pop r13                 ; przywróæ r13 - licznik pikseli w wierszu

;;;;;;;;;;;;;;;;;;;;;;;;;;;; tu sie konczy logika ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    inc r13                 ; Zwiêksz licznik pikseli w wierszu
    jmp loop_in_a_row       ; PrzejdŸ do kolejnego piksela

end_row:
    inc r10                     ; Zwiêksz licznik wysokoœci
    jmp loop_column_segment     ; PrzejdŸ do kolejnego wiersza

end_process:
    ret                         ; wyjdŸ z procedury
AddGaussianNoise ENDP

end