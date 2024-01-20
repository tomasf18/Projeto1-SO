#!/bin/bash


#-------------------------------------------#
#  Trabalho realizado por:                  #
#                                           #
#  Danilo Micael Gregório Silva   n 113384  #
#  Tomás Santos Fernandos         n 112981  #
#-------------------------------------------#


#-------------------------------------------------------------------------------------------------------------------------------------#


# Processamento dos argumentos:

# Opções possíveis de serem fornecidas pelo user, para filtrar os resultados ou para configurar a ordem de como é apresentado no output

option_r=false # ordenar por ordem inversa (ou seja, pela ordem correta do tamanho)
option_a=false # ordenar por nome


# Valores passados pelo user correspondentes às opções fornecidas:

sort="-n -r"	# variável com as opções de ordenação default
files=()        # esta variável irá conter os ficheiros "spacecheck" a comparar


# Criamos três array associativos organizados da seguinte maneira: keys->diretórios ; values->tamanhos correspondentes a cada diretório

declare -A firstOutput      # array associativo referente ao output do primeiro ficheiro passado como argumento
declare -A secondOutput     # array associativo referente ao output do segundo ficheiro passado como argumento
declare -A output           # array associativo que conterá o conteúdo do output final


# O comando 'getops' guarda as opções inseridas;
# Estas são especificadas na string abaixo '"ra"';
# As letras significam as opções disponíveis para o utilizador;
# As opções inseridas são então todas percorridas e é usado um case para verificar se 
#a opção armazenada na variável "$option" é uma das especificadas.

while getopts "ra" option; do
	case $option in	
		r)
			option_r=true
			sort="-n"
		;;
		a)
			option_a=true
			sort="-k 2" # -k serve para ordenar alfabeticamente, o 2 significa a segunda coluna, onde estão os nomes
		;;
	esac
done		


# Verificamos quais os argumentos passados que são do tipo ficheiro e adicionamo-los ao array "$files"

for arg in "$@"; do
	if [[ -e "$arg" && -f "$arg" ]]; then
		files+=("$arg")
	fi
done


# Em seguida, estão implementados dois ciclos que lêm o conteúdo de cada um dos ficheiros (um loop para cada ficheiro);
# Usamos "IFS= read -r linha" para ler as linhas de cada ficheiro, atribuindo cada linha à variável $linha;
# A leitura começa a ser feita a partir da segunda linha do mesmo, de modo a ignorarmos o cabeçalho, através do comando 'tail -n +2 "${files[1]}"'';
# Em cada iteração, filtramos os elementos da linha que nos interessam (campos SIZE e NAME), dividindo a linha em colunas,
#usando o comando "awk '{print $1}'" para dar-nos a primeira coluna (tamanho do diretório), e o comando "awk '{print $2}'" para dar-nos a segunda (nome do diretório);
# Em cada iteração, armazenamos o tamanho do diretório na variável "$dirSize" e o nome do diretório na variável "$dirName";
# Depois verificamos se a linha tem algum caractere, e se não tiver, passa para a iteração seguinte;
# Se a condição for verdadeira, criamos uma nova entrada no array associativo correspondente ao ficheiro que estamos a ler no 
#loop (firstOutput para files[0] e secondOutput para files[1]);
# Esta entrada terá como key o nome do diretório, e como value o tamanho correspondente;
# No final de cada loop, usamos '< <(tail -n +2 "${files[1]}")' para continuar a ler o ficheiro enquanto este não acaba;
# Desta forma, conseguimos ter o conteúdo de cada ficheiro passado como argumento organizado da mesma maneira, para posterior 
#comparação e operações necessárias entre os dois;

# tail -n, --lines=[+]N          imprime as últimas N linhas em vez das últimas 10;
                               # ou usa -n +N para imprimir começando na linha N

while IFS= read -r linha; do
    dirSize=$(echo $linha | awk '{print $1}')
    dirName=$(echo $linha | awk '{print $2}')
    
    # ATENÇÃO: NÃO LÊ A ULTIMA LINHA, CASO ESTA NÃO SEJA EM BRANCO...

    if [[ "$linha" != "" ]]; then
        firstOutput[$dirName]=$dirSize
        #echo val $dirName ${firstOutput[$dirName]}
    fi
done < <(tail -n +2 "${files[0]}")

while IFS= read -r linha; do
    dirSize=$(echo $linha | awk '{print $1}')
    dirName=$(echo $linha | awk '{print $2}')

    if [[ "$linha" != "" ]]; then
        secondOutput[$dirName]=$dirSize
        #echo val $dirName ${secondOutput[$dirName]}
    fi
done < <(tail -n +2 "${files[1]}")



#-------------------------------------------------------------------------------------------------------------------------------------#


# Operações sobre os arrays associativos para obter o conteúdo do output:

# Aqui realizamos dois ciclos for para preencher o array associativo que conterá o conteúdo do output final

# O primeiro verifica, para cada chave (nome do diretório) do array associativo com o conteúdo do output do primeiro ficheiro, se a mesma está presente 
#no conjunto das chaves do array associativo com o conteúdo do output do segundo ficheiro, através de "[[ -v secondOutput["$keyFirst"] ]]";
# Caso esteja presente, então criamos uma nova entrada no array associativo que conterá o conteúdo do output final, cuja chave é o nome do diretório
#comum às duas, e o seu valor será a diferença entre os tamanhos do diretório presente no output do primeiro ficheiro spacechek e o do diretório presente
#no output do segundo ficheiro spacechek;
# Caso a key não esteja no segundo array associativo, criamos uma nova entrada no do output final com a key "*nome do diretório* REMOVED" e value "-100",
#para que assim seja fácil de representar a informação final (visto que se está no primeiro e não esstá no segundo, então quer dizer que foi removido)

for keyFirst in "${!firstOutput[@]}"; do
    if [[ -v secondOutput["$keyFirst"] ]]; then
        output[$keyFirst]=$(( ${firstOutput[$keyFirst]} - ${secondOutput[$keyFirst]} ))
    else 
        output["$keyFirst REMOVED"]=-100
    fi
done 


# O segundo ciclo verifica, para cada chave (nome do diretório) do array associativo com o conteúdo do output do segundo ficheiro, se a mesma não está presente 
#no conjunto das chaves do array associativo com o conteúdo do output do primeiro ficheiro, através de "[[ ! -v firstOutput["$keySecond"] ]];";
# Caso esteja presente, então criamos uma nova entrada no array associativo que conterá o conteúdo do output final, cuja chave é o nome do diretório
#novo no segundo ficheiro seguido da palavra "NEW", e o seu valor será o tamanho desse diretório no segundo spacecheck;

for keySecond in "${!secondOutput[@]}"; do
    if [[ ! -v firstOutput["$keySecond"] ]]; then
        output["$keySecond NEW"]=${secondOutput[$keySecond]}
    fi
done 


#-------------------------------------------------------------------------------------------------------------------------------------#

# Processamento do output:

# Finalmente, para começar a imprimir o output, imprimimos primeiro o cabeçalho
echo SIZE NAME

# E depois corremos todas as chaves do array associativo que contém o conteúdo do output final para imprimir o output como desejado
for key in "${!output[@]}"; do
    echo "${output[$key]} $key"
done | sort $sort


