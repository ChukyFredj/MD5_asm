
## Description

Ce projet contient une implémentation incomplète de l'algorithme MD5 en assembleur pour processeurs x86-64. L'objectif principal de ce code est de montrer les étapes de transformation de MD5, bien que certaines parties soient incomplètes ou simplifiées.

## Structure des sections

- **section .bss** : Cette section contient des déclarations de mémoire non initialisée pour l'état, le message et le résultat en hexadécimal.
- **section .data** : Cette section contient des données initialisées, comme les chiffres hexadécimaux utilisés pour convertir l'état final en une chaîne de caractères hexadécimale.
- **section .text** : Cette section contient le code exécutable, y compris les macros pour les étapes de transformation MD5 et les fonctions pour effectuer les calculs MD5 et afficher le résultat.

## Fonctions principales

1. **MD5_Transform** : Cette fonction réalise les transformations principales de l'algorithme MD5 en utilisant plusieurs étapes de transformation définies par des macros (`FF`, `GG`, `HH`, `II`). Ces macros exécutent les opérations logiques et arithmétiques nécessaires pour chaque étape de MD5.

2. **convert_to_hex** : Cette fonction convertit l'état final de MD5 en une chaîne de caractères hexadécimale pour une sortie lisible.

3. **_start** : Le point d'entrée du programme. Il initialise l'état et le message, appelle la fonction `MD5_Transform`, convertit l'état final en une chaîne hexadécimale, puis affiche le résultat.

## Utilisation

Pour assembler et lier ce programme, utilisez `nasm` et `ld`. Voici les étapes pour compiler et exécuter le programme :

1. Assemblez le code source avec `nasm` :
    ```sh
    nasm -f elf64 -o md5.o md5.asm
    ```

2. Lie le fichier objet avec `ld` :
    ```sh
    ld -o md5 md5.o
    ```

3. Exécutez le programme compilé :
    ```sh
    ./md5
    ```

Le programme affichera le résultat MD5 en hexadécimal du message initialisé dans le code (ici, "test").

## Remarques

- Cette implémentation est incomplète et simplifiée pour des raisons pédagogiques. Certaines optimisations et considérations de sécurité peuvent être nécessaires pour une utilisation en production.
- L'algorithme MD5 est considéré comme cryptographiquement cassé et inadapté pour des tâches de sécurité. Pour des applications nécessitant une forte sécurité, envisagez d'utiliser des algorithmes plus sécurisés comme SHA-256.