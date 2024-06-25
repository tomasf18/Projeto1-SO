# Trabalho Prático 1 - Gestão de Armazenamento: Monitorização do Espaço Ocupado

## Departamento de Electrónica, Telecomunicações e Informática da Universidade de Aveiro
Curso: Licenciatura em Engenharia Informática  
Cadeira: Sistemas Operativos  
Ano Letivo: 2023/2024 — 1º ano, 1º Semestre  
`Nota: 17`  

## Objetivo

Desenvolvimento de scripts em bash para monitorizar o espaço ocupado em disco por ficheiros com determinadas propriedades, facilitando a gestão do armazenamento.

## Guião

O objetivo é criar dois scripts em bash para monitorizar o espaço ocupado em disco e a sua variação ao longo do tempo por ficheiros com determinadas propriedades. Os scripts a desenvolver são os seguintes:

### 1. Script `spacecheck.sh`

Este script permite visualizar o espaço ocupado pelos ficheiros selecionados na(s) diretoria(s) passada(s) como argumento e em todas as suas subdiretorias. A seleção dos ficheiros a contabilizar pode ser realizada através de expressões regulares no nome dos ficheiros, data máxima de modificação dos ficheiros ou tamanho mínimo do ficheiro. A tabela gerada pode ser ordenada de várias formas e o número de linhas pode ser limitado.

#### Exemplos de Utilização:

```bash
./spacecheck.sh -n ".*sh" sop
./spacecheck.sh -r -n ".*sh" sop
./spacecheck.sh -a -n ".*sh" sop
./spacecheck.sh -l 2 sop
./spacecheck.sh -d "Sep 10 10:00" sop
./spacecheck.sh -s 1024 sop
./spacecheck.sh -s 1024 -l 1 sop
```

### 2. Script `spacerate.sh`

Este script compara dois ficheiros gerados pelo `spacecheck.sh` e apresenta a evolução do espaço ocupado, mostrando a diferença entre os espaços ocupados em ambas as execuções. Diretorias que existem apenas num dos ficheiros são também apresentadas e assinaladas de forma especial. A saída pode ser ordenada de diversas formas.

#### Exemplos de Utilização:

```bash
./spacerate.sh spacecheck_20230923 spacecheck_20220923
./spacerate.sh -r spacecheck_20230923 spacecheck_20220923
./spacerate.sh -a spacecheck_20230923 spacecheck_20220923
```

## Fases do Trabalho

1. Escrever o script `spacecheck.sh` de acordo com a especificação.
2. Escrever o script `spacerate.sh` de acordo com a especificação.

A estrutura da linha de comando dos scripts deve ser sempre validada para garantir que os parâmetros usados estão de acordo com o esperado.

O trabalho será realizado em grupos de 2 alunos. Durante a execução do trabalho, deve ser respeitado um código de ética rigoroso que impede o plágio, a execução do trabalho por elementos externos ao grupo ou a partilha de código entre grupos distintos.

A entrega do trabalho será realizada através do elearning.ua.pt e deverá incluir o código fonte da solução encontrada e um relatório descrevendo a abordagem usada para resolver o problema e os testes realizados para validar a solução, incluindo a bibliografia que suportou o desenvolvimento do trabalho.

Dicas: Alguns comandos úteis para este trabalho são `awk`, `bc`, `cat`, `cut`, `date`, `du`, `find`, `getopts`, `grep`, `head`, `ls`, `printf`, `sleep`, `sort`, `stat`.
