.data
head: .word 0                # Puntatore alla testa della lista
tail: .word 0                # Puntatore alla coda della lista
nodes_pool: .zero 150       # Spazio per 30 nodi (5 byte ciascuno)
next_free: .word nodes_pool   # Puntatore al prossimo nodo libero

listInput: .asciz "ADD(z)~ADD(d)~ADD(B)~ADD(0)~PRINT~REV~PRINT~REV~PRINT"  # Input di esempio
error_msg: .asciz "Comando malformato ignorato\n"
newline: .asciz "\n"

.text

main:
    li s0, 32 #min/spazio vuoto
    li s1, 125 #max
    li s2, 40 #parentesi aperta
    li s3, 41 #parentesi chiusa
    li s4, 126 #~
    
    li s5, 65 #A
    li s6, 68 #D
    li s7, 83 #S
    li s8, 80 #P
    li s9, 82 #R
    
    la a2, head
    la a3, tail
    la a4, next_free
    la a0, listInput
    jal process_commands
    li a7, 10
    ecall
    
process_commands:
    lb t0, 0(a0)
    addi a0, a0, 1
    
    beq t0, s0, process_commands #se spazio salto al prossimo carattere
    
    beq t0, s5, read_add
    beq t0, s6, read_del
    beq t0, s7, read_sort
    beq t0, s8, read_print
    beq t0, s9, read_rev
    ret

    
    
read_add:
    li t1, 65 #A
    li t2, 68 #D

    lb t0, 0(a0)
    addi a0, a0, 1
    bne t0, t2, lettura_fallita #se non D
    
    lb t0, 0(a0)
    addi a0, a0, 1
    bne t0, t2, lettura_fallita #se non D
    
    lb t0, 0(a0)
    addi a0, a0, 1
    bne t0, s2, lettura_fallita #se non parentesi aperta
    
    lb t0, 0(a0)
    addi a0, a0, 1
    blt t0, s0, lettura_fallita # se < 32
    bgt t0, s1, lettura_fallita #se > 125
    
    mv a1, t0         #a1 contiene il carattere da aggiungere
    
    lb t0, 0(a0)
    addi a0, a0, 1
    bne t0, s3, lettura_fallita #se non parentesi chiusa
    
   
    
    j conferma_add    #se tutto va bene

    
conferma_add:
    lb t0, 0(a0)    #t0 carattere attuale
    
    beq t0, s4, esegui_add # se ~ add valido
    beq t0, zero, esegui_add #se fine stringa add valido
    beq t0, s0, skip_conferma # se spazio skip
    j lettura_fallita #altrimenti lettura fallita
    
skip_conferma:
    addi a0, a0, 1
    j conferma_add
    
esegui_add:
    addi sp, sp, -16
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw a0, 12(sp)

    
    # Alloca nuovo nodo
    lw s0, 0(a4)        # Ottieni indirizzo libero
    addi a4, a4, 5    #vado al prossimo next_free
    sb a1, 0(s0)           # Scrivi DATA nel byte 0 di s0
    
    # Inizializza PAHEAD a 0 (4 byte)
    sw zero, 1(s0)
    
    #verifico se primo nodo
    lb t0, 0(a3)
    beqz t0, first_node    #se coda a3=0 vuol dire che sto aggiungendo il primo nodo
    
    # Aggiorna PAHEAD del vecchio tail
    sw s0, 1(a3)    #copio l'indirizzo del nuovo nodo al PHEAD della coda vecchia
    mv a3, s0    #il nuovo elemento diventa la coda
    j add_done

first_node:
    mv a2, s0          # Primo nodo = testa
    mv a3, s0        # Primo nodo = coda
    

add_done:
    #ripristino e vado a leggere il prossimo comando
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw a0, 12(sp)
    addi sp, sp, 16
    addi a0, a0, 1
    j process_commands
    
read_del:
    ret
    
read_sort:
    li t1, 79 #O
    li t2, 82 #R
    li t3, 84 #T

    lb t0, 0(a0)
    addi a0, a0, 1
    bne t0, t1, lettura_fallita #se non O
    
    lb t0, 0(a0)
    addi a0, a0, 1
    bne t0, t2, lettura_fallita #se non R
    
    lb t0, 0(a0)
    addi a0, a0, 1
    bne t0, t3, lettura_fallita #se non T
        
    j conferma_sort    #se tutto va bene
    
conferma_sort:
    lb t0, 0(a0)    #t0 carattere attuale
    
    beq t0, s4, esegui_sort # se ~ add valido
    beq t0, zero, esegui_sort #se fine stringa add valido
    beq t0, s0, skip_conferma_sort # se spazio skip
    j lettura_fallita #altrimenti lettura fallita
    
skip_conferma_sort:
    addi a0, a0, 1
    j conferma_sort
    
esegui_sort:
    addi sp, sp, -24
    sw ra, 0(sp)
    sw s0, 4(sp)    # Puntatore esterno
    sw s1, 8(sp)    # Puntatore interno
    sw s2, 12(sp)   # Puntatore temporaneo
    sw a0, 16(sp)  
    sw a1, 20(sp)   
    
    # Caso base: lista vuota o con un solo elemento
    lw t5, 0(a2)
    beqz t5, sort_done
    lw t5, 1(a2)
    beqz t5, sort_done
    
    # Inizializza puntatore esterno (a2 = head)
    mv s0, a2
    
outer_loop:
    lw t5, 0(s0)
    beqz t5, sort_done       # Fine ordinamento
    mv s1, a2               # Riparti dalla testa
    
inner_loop:
    lw t5, 1(s1)            # Prossimo nodo
    beqz t5, end_inner      # Se fine lista
    
    # Confronta i due caratteri
    lb a0, 0(s1)            # Carica char corrente
    lb a1, 0(t5)            # Carica char successivo
    jal compare_chars
    
    # Se in ordine sbagliato, scambia i DATA
    blez a0, no_swap
    lb t1, 0(s1)
    lb t2, 0(t5)
    sb t2, 0(s1)
    sb t1, 0(t5)
    
no_swap:
    mv s1, t5               # Avanza al prossimo nodo
    j inner_loop
    
end_inner:
    # Avanza puntatore esterno
    lw s0, 1(s0)
    j outer_loop
    
sort_done:
    # Trova la nuova coda (potrebbe essere cambiata)
    jal find_tail
    mv a3, a0
    
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw a0, 16(sp)  
    sw a1, 20(sp)  
    addi sp, sp, 24
    
    addi a0, a0, 1
    j process_commands

# Funzione per trovare la coda della lista
find_tail:
    mv a0, a2               # Parti dalla testa
    lw t5, 0(a0)
    beqz t5, tail_done      # Se lista vuota
    
tail_loop:
    lw t5, 1(a0)            # Prossimo nodo
    beqz t5, tail_done      # Se ¨¨ l'ultimo
    mv a0, t5               # Altrimenti avanza
    j tail_loop
    
tail_done:
    ret
    
compare_chars:
    # Input: a0 = char1, a1 = char2
    # Output: a0 = -1 (char1 < char2), 0 (uguali), 1 (char1 > char2)
    
    # Categorie: 3=maiuscole, 2=minuscole, 1=numeri, 0=altro
    li t0, 65
    blt a0, t0, not_upper1
    li t0, 90
    ble a0, t0, upper1
    
not_upper1:
    li t0, 97
    blt a0, t0, not_lower1
    li t0, 122
    ble a0, t0, lower1
    
not_lower1:
    li t0, 48
    blt a0, t0, extra1
    li t0, 57
    ble a0, t0, number1
    j extra1
    
upper1:
    li t1, 3    # Categoria pi¨´ alta
    j cat2
lower1:
    li t1, 2
    j cat2
number1:
    li t1, 1
    j cat2
extra1:
    li t1, 0

cat2:
    # Determina categoria per char2
    li t0, 65
    blt a1, t0, not_upper2
    li t0, 90
    ble a1, t0, upper2
    
not_upper2:
    li t0, 97
    blt a1, t0, not_lower2
    li t0, 122
    ble a1, t0, lower2
    
not_lower2:
    li t0, 48
    blt a1, t0, extra2
    li t0, 57
    ble a1, t0, number2
    j extra2
    
upper2:
    li t2, 3
    j compare_cat
lower2:
    li t2, 2
    j compare_cat
number2:
    li t2, 1
    j compare_cat
extra2:
    li t2, 0

compare_cat:
    bne t1, t2, compare_diff_cat
    # Stessa categoria, confronta ASCII
    blt a0, a1, less
    beq a0, a1, equal
    j greater
    
compare_diff_cat:
    blt t1, t2, less
    j greater
    
less:
    li a0, -1
    ret
equal:
    li a0, 0
    ret
greater:
    li a0, 1
    ret
    
    
    
read_print:
    li t1, 82 #R
    li t2, 73 #I
    li t3, 78 #N
    li t4, 84 #T

    lb t0, 0(a0)
    addi a0, a0, 1
    bne t0, t1, lettura_fallita #se non R
    
    lb t0, 0(a0)
    addi a0, a0, 1
    bne t0, t2, lettura_fallita #se non I
    
    lb t0, 0(a0)
    addi a0, a0, 1
    bne t0, t3, lettura_fallita #se non N
    
    lb t0, 0(a0)
    addi a0, a0, 1
    bne t0, t4, lettura_fallita #se non T
        
    j conferma_print    #se tutto va bene
    
conferma_print:
    lb t0, 0(a0)    #t0 carattere attuale
    
    beq t0, s4, esegui_print # se ~ add valido
    beq t0, zero, esegui_print #se fine stringa add valido
    beq t0, s0, skip_conferma_print # se spazio skip
    j lettura_fallita #altrimenti lettura fallita
    
skip_conferma_print:
    addi a0, a0, 1
    j conferma_print
    
esegui_print:
    addi sp, sp, -16
    sw ra, 8(sp)
    sw s0, 4(sp)
    sw s1, 0(sp)
    sw a0, 12(sp)
    
    lb t0, 0(a2)
    beqz t0, end_print
    # Salva nodo corrente in s0
    mv s0, a2
    
    #inizio dalla testa
    
print_list:
    # Leggi il carattere dal nodo (byte 0)
    lb a0, 0(s0)
    
    # Stampa il carattere (usa syscall)
    li a7, 11          # Codice syscall per print_char
    ecall
    
    # Prepara la chiamata ricorsiva con il prossimo nodo
    lw t0, 1(s0)       # Carica PAHEAD (indirizzo prossimo nodo)
    beqz t0, end_print
    mv s0, t0
    
    # Chiamata ricorsiva
    jal print_list
    
end_print:
    # Epilogo - ripristina registri
    lw s1, 0(sp)
    lw s0, 4(sp)
    lw ra, 8(sp)
    lw a0, 12(sp)
    addi sp, sp, 16
    
    addi a0, a0, 1
    j process_commands

read_rev:
    li t1, 69 #E
    li t2, 86 #V

    lb t0, 0(a0)
    addi a0, a0, 1
    bne t0, t1, lettura_fallita #se non E
    
    lb t0, 0(a0)
    addi a0, a0, 1
    bne t0, t2, lettura_fallita #se non V
        
    j conferma_rev    #se tutto va bene
    
conferma_rev:
    lb t0, 0(a0)    #t0 carattere attuale
    
    beq t0, s4, esegui_rev # se ~ add valido
    beq t0, zero, esegui_rev #se fine stringa add valido
    beq t0, s0, skip_conferma_rev # se spazio skip
    j lettura_fallita #altrimenti lettura fallita
    
skip_conferma_rev:
    addi a0, a0, 1
    j conferma_rev
    
esegui_rev:
    addi sp, sp, -16
    sw ra, 0(sp)
    sw s0, 4(sp)    # Puntatore prev (precedente)
    sw s1, 8(sp)    # Puntatore curr (corrente)
    sw s2, 12(sp)   # Puntatore next (successivo)
    
    # Caso base: lista vuota o con un solo elemento
    lw t0, 0(a2)
    beqz t0, rev_done               # Se head == NULL, finisci
    lw t0, 1(a2)                    # Controlla se c'¨¨ solo un elemento
    beqz t0, rev_done               # Se head->next == NULL, finisci
    
    # Inizializza i puntatori
    mv s1, a2                      # curr = head
    mv s0, zero                    # prev = NULL
    
rev_loop:
    # Salva il prossimo nodo
    lw s2, 1(s1)                   # next = curr->next
    
    # Inverte il puntamento
    sw s0, 1(s1)                   # curr->next = prev
    
    # Avanza i puntatori
    mv s0, s1                      # prev = curr
    mv s1, s2                      # curr = next
    
    # Continua finch¨¦ curr != NULL
    bnez s1, rev_loop
    
    # Aggiorna head e tail
    mv a3, a2                      # La vecchia head diventa la nuova tail
    mv a2, s0                      # L'ultimo nodo (prev) diventa la nuova head
    
rev_done:
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    addi sp, sp, 16
    
    addi a0, a0, 1                 # Avanza al prossimo comando
    j process_commands
    
lettura_fallita:
    search_tilde:
    lb t0, 0(a0)    #t0 carattere attuale
    addi a0, a0, 1
    beq t0, s4, process_commands # se ~ prossimo comando
    beq t0, zero, end_main #se fine stringa add valido
    j search_tilde
    
    
end_main:
    li a7, 10
    ecall