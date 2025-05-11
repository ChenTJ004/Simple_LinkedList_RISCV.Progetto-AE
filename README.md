# Progetto RISC-V – Gestione di Liste Concatenate

**Corso:** Architetture degli Elaboratori  
**Anno Accademico:** 2024/2025  

## 📌 Obiettivo del progetto

Implementare in linguaggio Assembly RISC-V un gestore di **liste concatenate semplici**, supportando le seguenti operazioni:

- `ADD(char)` – Inserimento di un elemento in coda
- `DEL(char)` – Eliminazione di tutti gli elementi con valore `char`
- `PRINT` – Stampa ricorsiva della lista
- `SORT` – Ordinamento crescente secondo regole ASCII personalizzate
- `REV` – Inversione della lista usando lo stack

Ogni elemento della lista occupa 5 byte:
- 1 byte per il dato (carattere ASCII)
- 4 byte per il puntatore all’elemento successivo (`PAHEAD`)


- Gli input vengono letti da una stringa `listInput` nel `.data`, con comandi separati da `~`.
- L’ordinamento ASCII considera la seguente precedenza: **maiuscole > minuscole > numeri > simboli**.
- L'implementazione privilegia la **modularità**, ogni operazione è realizzata come procedura separata.

