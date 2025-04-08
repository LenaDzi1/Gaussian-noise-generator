; AsmLib.asm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Autor: Lena Dziurska
; Rok/semestr: 2024/25, semestr 5, J�zyki Asemblerowe
;
; Temat: Dodawanie szumu gausowaskiego do obrazu 
; Opis algorytmu: Dodawanie szumu do obrazu z wykorzystaniem transformaci Box-Mullera.
; Generowane s� dwie liczby z zakresu (0,1), kt�re nasepnie przekszta�cane 
; s� zgodnie ze wzorami z transformacji.
; Zgodnie z wyborem u�ytkownika kolor obrazu mo�e zosta� zamieniony tak�e na skal� szaro�ci.
; 
; Wersja: 1.0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


.data
;;;;;;;;;;; STA�E I DANE W ASM: ;;;;;;;;;;;;;;;;;;;;;;

    two_to_64 REAL8 1.0842021724855044E-19  ; 2^(-64) w formacie zmiennoprzecinkowym (REAL8)

    zero        dq 0.0 
    one         dq 1.0    
    two         dq 2.0
    three       dq 3.0
    neg_one     dq -1.0    
    neg_two     dq -2.0     
    pi          dq  3.14159

    red         dq 0.299        ; waga dla kana�u R
    green       dq 0.587        ; waga dla kana�u G
    blue        dq 0.114        ; waga dla kana�u B
  
    result REAL8 0.0  ; To store the result  
    value  QWORD 1.0  ; Example value (use whatever is in RAX)



.code

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; FUNKCJA ZMIENIAJ�CA OBRAZ NA SKAL� SZARO�CI ;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Grayscale_Conversion PROC
    ;Procedura zamiany bitmapy na odcienie szaro�ci z wykorzytsaniem wag kana��w RBG [odcienie szaro�ci dla ludzkiego oka]

    ; Przekazane zmienne:
    ; rcx - wska�nik na pierwszy pixel bitmapy (unsigned char)
    ; rdx - szeroko��
    ; r8  - wysoko�� min
    ; r9  - wysoko�� max

    ; Inne zmienne:
    ; r15 - licznik wysoko�ci
    ; r14 - sta�a szeroko��x4
    ; r13 - licznik pikseli w wierszu
    ; r12 - wska�nik na piksel w pierwszej kolumnie
    ; r11 - wska�nik na piksel w wierszu



    xor r15, r15             ; r15 - licznik wysoko�ci; b�dzie por�wnywany z wysoko��_max [r9] aby zako�czy� procedur�
    mov r15, r8              ; inicjalizujemy licznik wysoko�ci [r15] wysoko�ci� min [r8]
    
    mov r14, rdx             ; przenosimy szeroko�� obrazu do rejestru r14
    imul r14, 4              ;rejestr r14 mno�ymy x4 - r14 to szeroko�� z uzgl�dnieniem RGBA

loop_column_segment:
    cmp r15, r9              ; Por�wnanie licznika wysoko�ci z wysoko��_max
    jge end_process          ; jesli koniec obrazu, ko�czymy proces

    xor r13, r13             ; r13 = 0, licznik pikseli w wierszu

    mov r12, r15             ; r12 = licznik wysoko�ci
    imul r12, r14            ; mno�ymy przez szeroko�� RGBA [x4] - u nas sta�a w r14
    add r12, rcx             ; dodajemy wska�nik do pierwszego piksela - r12 = wska�nik na pierwszy piksel

loop_in_a_row:
    cmp r13, rdx             ; por�wnujemy piksele w wierszu z jego szeroko�ci�
    jge end_row              ; Dotarli�my do ko�ca wiersza, ko�czymy p�tl�

    mov r11, r13             ; r13 = licznik pikseli w wierszu
    imul r11, r11, 4         ; mno�ymy x4 [jakby "szeroko�� piksela"] z uwagi na RGBA
    add r11, r12             ; Dodajemy wska�nik pierwszego piksela [r12] - r11 = wska�nik pikseli w wierszu


    ;//////////// Dla kana�u R ///////////////
    movzx ebx, byte ptr [r11+2]        ; Wczytujemy kana� R do ebx
    movd xmm0, ebx                     ; Przenosimy go do rejestru zmeinnoprzecinkowego xmm0
    movsd xmm1, [red]                  ; Do rejestru xmm1 wstawiamy wag� czerwieni [Red]
    mulsd xmm0, xmm1                   ; mno�ymy obecn� warto�� kana�u przez wag�
    movd ebx, xmm0                     ; wynik z powrotem w ebx
    mov eax, ebx                       ; przenosimy t� warto�� do eax [akumulator]

    ;//////////// Dla kana�u G ///////////////
    movzx ebx, byte ptr [r11+1]      ; Wczytujemy kana� G do ebx
    movd xmm0, ebx                   ; Przenosimy go do rejestru zmeinnoprzecinkowego xmm0
    movsd xmm1, [green]              ; Do rejestru xmm1 wstawiamy wag� zieleni [Green]
    mulsd xmm0, xmm1                 ; mno�ymy obecn� warto�� kana�u przez wag�
    movd ebx, xmm0                   ; wynik z powrotem w ebx
    add eax, ebx                     ; dodajemy t� warto�� do akumulatora [R+G]

    ;//////////// Dla kana�u B ///////////////
    movzx ebx, byte ptr [r11]        ; Wczytujemy kana� B do ebx
    movd xmm0, ebx                   ; Przenosimy go do rejestru zmeinnoprzecinkowego xmm0
    movsd xmm1, [blue]               ; Do rejestru xmm1 wstawiamy wag� b��kitu [Blue]
    mulsd xmm0, xmm1                 ; mno�ymy obecn� warto�� kana�u przez wag�
    movd ebx, xmm0                   ; wynik z powrotem w ebx
    add eax, ebx                     ; dodajemy t� warto�� do akumulatora [R+G+B]

    mov byte ptr [r11+2], al         ; Przenosimy warto�� do kana�u R
    mov byte ptr [r11+1], al         ; Przenosimy warto�� do kana�u G
    mov byte ptr [r11], al           ; Przenosimy warto�� do kana�u B


    inc r13                    ; Zwi�kszamy licznik pikseli w wierszu
    jmp loop_in_a_row          ; Przechodzimy do kolejnego piksela w danym wierszu

end_row:
    inc r15                    ; Zwi�kszamy licznik wysoko�ci
    jmp loop_column_segment    ; Przechodzimy do kolejnego wiersza

end_process:
    ret                         ; powr�t z procedury
Grayscale_Conversion ENDP




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; FUNKCJA DODAJ�CA SZUM DO OBRAZU ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

AddGaussianNoise PROC
    ; Procedura dodaj�ca szum gaussowski do obrazu. Wykorzystuje metod� Box-Mullera.
    ; Wykorzystuje generowanie liczb losowych z procesora oraz 
    ; wykorzystuje szereg Maclaurina to wyliczenia ln(X1).

    ; Przekazane zmienne:
    ; rcx - wska�nik na pierwszy pixel bitmapy (unsigned char)
    ; rdx - szeroko��
    ; r8  - wysoko�� min
    ; r9  - wysoko�� max / iteracje Maclaurin
    ; xmm0 - odchylenie standardowe [dev]

    ; Inne zmienne:
    ; r15 - flaga przechowywania drugiej wylosowanej warto�ci [0 lub 1]
    ; r14 - sta�a szeroko��x4
    ; r13 - licznik pikseli w wierszu / Rand2 / licznik kana�u w pikselu
    ; r12 - wska�nik na piksel w pierwszej kolumnie
    ; r11 - wska�nik na piksel w wierszu / Rand1
    ; r10 - licznik wysoko�ci

    ; Zmiennoprzecinkowe:
    ; xmm1 - Rand1 / X1 / [X1-1] / [X1-1]/N  / ln(X1) / (-2 ln(X1)) / sqrt (-2 ln(X1))
    ; xmm2 - 2 ^ (-64) / 0.0 / X1^2 / S / X1-1 / sqrt (-2lnX1) / sqrt (-2lnX1) * sin / z1*dev
    ; xmm3 - Rand2 / X2 /  3.14 * X2/ 2*3.14*X2  / sqrt (-2lnX1) / sqrt (-2lnX1)* cos / z2*dev
    ; xmm4 - -1.0 / X2^2 / 1.0/ n indeks/ -2.0 / 3.14 / 2.0 / 0.0 / dev
    ; xmm5 - ln(X1) / 0.0
    ; xmm6 - 1.0 /0.0
    ; xmm7 - sin (2 3.14 x2) / 0.0
    ; xmm8 - cos (2 3.14 x2) / 0.0



    xor r10, r10             ; r10 - licznik wysoko�ci; b�dzie por�wnywany z wysoko��_max [r9] aby zako�czy� procedur�
    mov r10, r8              ; inicjalizujemy licznik wysoko�ci [r10] wysoko�ci� min [r8]
    
    mov r14, rdx             ; przenosimy szeroko�� obrazu do rejestru r14
    imul r14, 4              ; rejestr r14 mno�ymy x4 - r14 to szeroko�� z uzgl�dnieniem RGBA

loop_column_segment:
    cmp r10, r9              ; Por�wnanie licznika wysoko�ci z wysoko��_max
    jge end_process          ; jesli koniec obrazu, ko�czymy proces

    xor r13, r13             ; r13 = 0, licznik pikseli w wierszu

    mov r12, r10             ; r12 = licznik wysoko�ci
    imul r12, r14            ; mno�ymy przez szeroko�� RGBA [x4] - u nas sta�a w r14
    add r12, rcx             ; dodajemy wska�nik do pierwszego piksela - r12 = wska�nik na pierwszy piksel

loop_in_a_row:
    cmp r13, rdx             ; por�wnujemy piksele w wierszu z jego szeroko�ci�
    jge end_row              ; Dotarli�my do ko�ca wiersza, ko�czymy p�tl�

    mov r11, r13             ; r13 = licznik pikseli w wierszu
    imul r11, r11, 4         ; mno�ymy x4 [jakby "szeroko�� piksela"] z uwagi na RGBA
    add r11, r12             ; Dodajemy wska�nik pierwszego piksela [r12] - r11 = wska�nik pikseli w wierszu

    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  tu sie zaczyna logika ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 Normal_distribution:   
    cmp r15, 1               ; Sprawdzamy wyst�pienie drugiej warto�ci - flaga r15
    je  flag_one             ; Je�li mamy warto�� to jej nie generujemy - skok do "flag_one"


    ;;;;;;;;;;;;;;;;; Generowanie warto�ci losowych ;;;;;;;;;;;;;;;;;;;;;
generate_values:
    
    push r13                ; odk�adamy licznik pikseli [r13] na stos
    push r11                ; odk�adamy wska�nik na pixel w wierszu [r11] na stos
        
    ; Generowanie losowych warto�ci X1 i X2
    rdrand r11              ; Zapisuje losow� warto�� 64-bitow� do r11

    ; Przekszta�cenie liczby ca�kowitej na zmiennoprzecinkow� (X1)
    cvtsi2sd xmm1, r11      ; Konwertujemy 64-bitow� liczb� ca�kowit� na zmiennoprzecinkow� (XMM1)

    ; Dzielimy przez 2^64, aby uzyska� liczb� w przedziale (0, 1)
    movsd xmm2, [two_to_64]   ; Za�aduj 2^(-64) do xmm2
    mulsd xmm1, xmm2          ; Mno�ymy XMM1 (losowa liczba) przez 2^(-64) z xmm2


; Powtarzamy dla drugiej liczby
    rdrand r13                ; Zapisuje losow� warto�� 64-bitow� do r13
    cvtsi2sd xmm3, r13        ; Konwertujemy 64-bitow� liczb� ca�kowit� na zmiennoprzecinkow� (XMM3)


    pop r11                   ; przywr�cenie r13 ze stosu - ju� nie bedzie nam potrzebny dodatkowy rejestr
    pop r13                   ; przywr�cenie r11 ze stosu - ju� nie bedzie nam potrzebny dodatkowy rejestr

    mulsd xmm3, xmm2          ; Mno�ymy XMM2 (losowa liczba) przez 2^(-64) z xmm2


    movsd XMM2, [zero]        ; Wczytaj 0.0 do XMM2 (dla double)
    movsd XMM4, [neg_one]     ; Wczytaj -1.0 do XMM4 (dla double)
    comisd XMM1, XMM2         ; Por�wnaj XMM1 z XMM2 (XMM2 zawiera 0.0)


 
    jz generate_values      ; Jesli wygenerowana warto�� to 0 - powt�rz losowanie
    comisd XMM1, XMM2       ; Por�wnaj XMM1 z XMM2 (XMM2 zawiera 0.0)
    jae positivex1          ; je�li warto�� jest dodatnia, pomi� mno�enie -1

    mulsd xmm1, xmm4        ; negatywna warto�� - zamiana znaku, mno�enie *-1.0

positivex1:
    comisd XMM3, XMM2      ; Por�wnaj XMM3 z XMM2 (XMM2 zawiera 0.0)
    jz generate_values     ; Jesli wygenerowana warto�� to 0 - powt�rz losowanie
    comisd XMM3, XMM2      ; Por�wnaj XMM3 z XMM2 (XMM2 zawiera 0.0)
    jae positivex2         ; je�li warto�� jest dodatnia, pomi� mno�enie -1

    mulsd xmm3, xmm4        ; negatywna warto�� - zamiana znaku, mno�enie *-1.0
    
positivex2:
    movsd XMM2, XMM1        ; kopiuj X1 do xmm2
    movsd XMM4, XMM3        ; kopiuj X2 do xmm4

    mulsd XMM2, XMM2        ;do kwadratu XMM2 czyli nasze X1
    mulsd XMM4, XMM4        ;do kwadratu XMM4 czyli nasze X2

    addsd XMM2, XMM4         ; xmm2 = suma kwadrat�w liczb
    movsd XMM4, [one]        ; Wczytaj 1.0 do XMM3 (dla double)
    comisd XMM2, XMM4        ; por�wnaj sum� z 1
    jae generate_values      ; je�li suma jest wi�ksza od 1, wygeneruj nowe warto�ci

 ; Je�li suma jest < 1, przechodzimy do dalszych oblicze�

    ;;;;;;;;;;;;;;;;;; koniec generowania warto�ci ;;;;;;;;;;;;;;;;;;;;





    ;;;;;;;;;;;;;;;;;; obliczanie szeregu Maclaurina ln (X1) ;;;;;;;;;;;;;;;

    subsd XMM1, XMM4           ; XMM1 = X1 - 1
    movsd XMM2, XMM1           ; kopia (x1-1) w xmm2 - to b�dzie nasz mno�nik licznika
    movsd XMM6, XMM4           ; XMM6 = 1 sk�adnik dla sumy mianownika, XMM4 = 1 nasz mianownik

    push r9                     ; od�� wysoko��_max [r9] na stos

    xor r9, r9                  ; r9 = 0 (licznik iteracji w rozwini�ciu szeregu)
    xorpd XMM5, XMM5            ; XMM5 = 0, czy�cimy rejestr

Loop_Macl:
    cmp r9, 100          ; Sprawdzamy, czy r9 >= 100, czy wyst�pi�o tyle iteracji
    jge End_Macl            ; Je�li tak, ko�czymy p�tl�


    divsd xmm1, xmm4          ; xmm1 = xmm1 / xmm4 (dzielenie)
    addsd XMM5, XMM1          ; dodanie sk�adnika szeregu do zmiennej wynikowej
       
    mulsd xmm1, xmm4          ; mno�enie by przywr�ci� licznik 
    mulsd XMM1, XMM2          ; XMM1 *= XMM2 (mno�enie przez X1-1)
    addsd XMM4, XMM6          ; Zwi�kszamy XMM4 (indeks)
    inc r9                    ; Zwi�kszamy licznik iteracji

    divsd xmm1, xmm4         ; xmm1 = xmm1 / xmm4 (dzielenie)
    subsd XMM5, XMM1         ; odjecie sk�adnika szeregu od zmienej wynikowej
  
    mulsd xmm1, xmm4         ; mno�enie by przywr�ci� licznik
    mulsd XMM1, XMM2         ; XMM1 *= XMM2 (mno�enie przez X1-1)
    addsd XMM4, XMM6         ; Zwi�kszamy XMM4 (indeks)
    inc r9                   ; Zwi�kszamy licznik iteracji

    jmp Loop_Macl           ; Wracamy do pocz�tku p�tli


End_Macl:

    ;;;;;;;;;;;;;;;;; koniec wyznaczania warto�ci ln(X1) szeregu Maclaurina ;;;;;;;;;;;;;;;;;;;;;;;;;;
; w XMM1 = Pot�gi X1-1  ; w XMM2 = X1-1; w XMM3 = X2,  w XMM4 = liczba n*1  iteracji, w XMM5 = ln (X1), w XMM6 = 1
    
    
    
    pop r9              ; Przywracamy r9 - wys_max

    movsd XMM1, XMM5    ; przenosimy wynik ln(X1) do XMM1

    ; mno�enie przez -2
    movsd XMM4, [neg_two]                 ; -2.0 do rejestru xmm4
    mulsd XMM1, XMM4 ; -2ln(X1) W XMM0    ; mno�my logarytm przez -2 

    sqrtsd XMM1, XMM1                     ; pierwiastek z tego, xmm1 = sqrt (-2ln(X1))

    ;mno�enie przez 2pi
    movsd XMM4, [pi]                      ; xmm4 = pi
    mulsd XMM3, XMM4                      ; zmm3 = X2*pi  

    movsd XMM4, [two]                     ; xmm4 = 2
    mulsd XMM3, XMM4                      ; XMM3 = 2piX2
        
    movsd qword ptr [value], xmm3     ; przenosimy warto�� z xmm3 do zmiennej [value]
 
    ;; liczymy sin (2piX2)
    fld [value]                       ; Za�adowanie [value] z pamieci do stostu FPU (ST(0)
       
    
    fsin                             ; teraz st(0) = sin( st(0) );
    fstp result                      ; wynik przechowywany w result [pop the FPU stack]
    movsd xmm7, [result]             ; warto�� z [result] zapisywana do xmm7 = sin(2piX2)


    ;; powtarzamy dla cos(2piX2)
    fld [value]                     ; Za�adowanie [value] z pamieci do stostu FPU (ST(0)v
       
    
    fcos                           ; teraz st(0) = cos( st(0) );
    fstp result                    ; wynik przechowywany w result [pop the FPU stack]
    movsd xmm8, [result]           ; warto�� z [result] zapisywana do xmm8 = cos(2piX2)

    movsd xmm2, xmm1                ;przenosimy sqrt(-2ln(X1)) do xmm2
    movsd xmm3, xmm1                ;przenosimy sqrt(-2ln(X1)) do xmm3

    mulsd xmm2, xmm7        ; xmm2 = Z1     sqrt(-2ln(X1)) * sin(2piX2)
    mulsd xmm3, xmm8        ; xmm3 = Z2     sqrt(-2ln(X1)) * cos(2piX2)

    ;;;;;;;;; wyczy�ci� xmm 4, 5, 6, 7, 8
    movsd xmm4, [zero]
    movsd xmm5, [zero]
    movsd xmm6, [zero]
    movsd xmm7, [zero]
    movsd xmm8, [zero]


    mov r15, 1                  ; flaga = 1, wygenerowali�my ju� 2 warto�ci, jedna jest od�o�ona

    mulsd xmm2, xmm0            ; mno�enie Z1 przez odchylenie standardowe
    mulsd xmm3, xmm0            ; mno�enie Z2 przez odchylenie standardowe

    push r13                    ; od�o�enie r13 - licznik pikseli w wierszu
	mov r13, r11                ; r13 - licznik kana�u w pikselu
	add r13, 3                  ; r13 = r11 + 3 czyli kana� A [r11 - wska�nik na piksel]

	
to_jest_petla:
	cvttsd2si eax, xmm2              ; Z1 w eax; og�lnie r15 = 1 czyli mamy od�ozon� warto�� z2, korzystamy z z1
_dla_r15:
    movzx ebx, byte ptr [r11]        ; Wczytaj kana� do ebx
    add eax, ebx                     ; Dodaj wynik do eax = chanel_value + Z1
   
    cmp eax, 255                      ; por�wnaj z 255
    jge _value255                     ; je�li >255 poza zakresem idz do _value255
    cmp eax, 0                        ; por�wnaj z 0
    jbe _value0                       ; je�li <0 poza zakresem id� do _value0
    jmp next                          ; id� dalej

_value255:                      
    mov eax, 255                        ; wpisz 255 do akumulatora
    jmp next                            ; id� dalej
_value0:
    mov eax, 0                          ; wpisz 0 do akumulatora
next:
    mov byte ptr [r11], al           ; Wpisz warto�c z akumulatora do aktualnego kana�u
	inc r11                          ; inkrementacja wska�nika na kana� 
	cmp r11, r13                     ; por�wnaj z r13, czy przeszli�my ju� przez wszystkie kana�y RGB
	je continue                      ; je�li tak, wyjd� z p�tli [kontynuuj]   
	cmp r15, 1                       ; sprawd� flag� na r15 [1 = mamy niewykorzystan� drug� warto��]
	je to_jest_petla                 ; je�li tak id� do pocz�tku p�tli
    jmp zapis_xmm3                   ; je�li zero, id� do przypadku z wykorzystaniem Z2
	
	
	
    jmp continue            ;wyjd� z p�tli [kontynuuj]

flag_one:
	mov r15, 0              ;zerowanie flagi
	push r13                ; od�o�enie r13 - licznik pikseli w wierszu
	mov r13, r11            ; r13 - licznik kana�u w pikselu
	add r13, 3              ; r13 = r11 + 3 czyli kana� A [r11 - wska�nik na piksel]
	
zapis_xmm3:
	cvttsd2si eax, xmm3     ; w przypadku r15 = 0 [wykorzytujemy warto�� z2]
	jmp _dla_r15            ; skok do "reszty p�tli"
    

continue:
    pop r13                 ; przywr�� r13 - licznik pikseli w wierszu

;;;;;;;;;;;;;;;;;;;;;;;;;;;; tu sie konczy logika ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    inc r13                 ; Zwi�ksz licznik pikseli w wierszu
    jmp loop_in_a_row       ; Przejd� do kolejnego piksela

end_row:
    inc r10                     ; Zwi�ksz licznik wysoko�ci
    jmp loop_column_segment     ; Przejd� do kolejnego wiersza

end_process:
    ret                         ; wyjd� z procedury
AddGaussianNoise ENDP

end