#!/bin/bash


#-------------------------------------------#
#  Trabalho realizado por:                  #
#                                           #
#  Danilo Micael Gregório Silva   n 113384  #
#  Tomás Santos Fernandes         n 112981  #
#-------------------------------------------#


#-------------------------------------------------------------------------------------------------------------------------------------#


# Funções a serem usadas no script:

# Função para imprimir o cabeçalho
function print_head() {
	d1=$(date +%Y%m%d)	# "date [OPÇÃO]... [+FORMATO] -> neste caso queríamos que o formato fosse AnoMêsDia"

	# Cabeçalho sem os argumentos passados pelo user
	cabecalho="SIZE NAME $d1"
	
	# Adicionar os argumentos ao cabeçaho
	for option in "$@" ; do
		cabecalho="$cabecalho $option"
	done

	echo $cabecalho
}


# Verificar se o argumento é uma data válida
function is_date() {
	# O comando "**comando anterior** &>/dev/null" faz com que a saída padrão (stdout - "standard output" -, caso não haja erros) 
	#ou com que os avisos/saída de erro padrão (stderr - "standard error" -, caso existam) do "**comando anterior**" sejam redirecionados 
	#para um caminho que os descartará (um dispositivo como um "poço sem fundo"), fazendo com que nada seja mostrado no terminal, tanto no 
	#caso de haver erros (se o comando contiver algum erro, como por exemplo a data entre aspas em '--date="$1"' ser inválida) como no caso 
	#de correr tudo bem (ou seja, o output habitual do comando também não seria mostrado, e também seria redirecionado e descartado)

	if date --date="$1" &>/dev/null; then 							  
		return 0 # 0 se é uma data válida					 
	else
		return 1 # 1 se é uma data inválida
	fi
}


# Veriificar se o argumento é inteiro >= 0
function is_integer_positive() {
	if [[ $1 =~ ^[0-9]+$ ]]; then
		return 0 # 0 se é inteiro positivo (inclui 0)
	else
		return 1 # 1 se não é inteiro positivo
	fi
}


# Imprimir o output
function print_output() {
	
	dir="$1"	# Atribuímos a $dir o(um dos) diretório(s) inseridos pelo user
	
	# Usamos o comando "find" para encontrar todos os elemtentos dentro de $dir que sejam do tipo diretório (-d), redirecionamos e descartamos a mensagem de erro
	#no caso de não ser possível lê-lo, e, por fim, usando um pipe percorremos todos os subdiretórios obtidos com o comando "find"
	find "$dir" -type d 2>/dev/null | while read -r subdir; do
		# Verificamos se o $subdir tem permissão para ser lido

		# Usamos este ciclo para percorrer todos os subdiretórios de $subdir e verificar se têm permissão de leitura
		# Caso contrário é definido o valor da variável $permission como false e saímos do ciclo
		while read -r subdir_2; do
		    permission="true"
		    if [ ! -r "$subdir_2" ]; then
		        permission="false"
		        break
		    fi
		done < <(find "$subdir" -type d 2>/dev/null)



		if [ "$permission" = "true" ]; then
	
			dir_size="0"	# Inicialmente definimos o tamanho do $subdir com 0
			
			# Usamos esta estrutura condicional para encontrar (find) em $subdir ("$subdir") todos os ficheiros (-type f) com a expressão desejada (-regex "$file_pattern")
	        # E caso exista algum erro, para não aparecerem mensagens no output, visto que já estamos a lidar com elas, redirecionamo-las e descartamo-las
			if [ "$option_n" = true ]; then
				files=$(find "$subdir" -type f -regex "$file_pattern" 2>/dev/null)
			else
				files=$(find "$subdir" -type f 2>/dev/null)
			fi
			
			# Verificamos também se $files não se encontra vazia
			if [ -n "$files" ]; then 	# Condição verdadeira se $files não está vazia
			
				# Em seguida percorremos um a um os ficheiros filtrados (ou não filtrados, caso não tenha sido usada a opção "-n") em $files
				while read -r file; do
					

					file_size=$(stat -c "%s" "$file") # Obtemos o tamanho do ficheiro em bytes
					
					if [ $? -ne 0 ]; then # se o comando stat falhar é definido dir_size como NA e saímos do ciclo
						dir_size="NA"
						break
					fi

					# Na seguinte estrutura condicional, caso a opção "-d" tenha sido selecionada, filtramos tanto por data como por tamanho mínimo (este último 
					#está guardado na variável $size inicializada com 0 fora da função, e caso o user não tenha decidido passar um tamanho mínimo como argumento, 
					#este é, então, igual a 0); se a opção "-d" não tiver sido usada, então filtramos apenas por tamanho mínimo
					if [ "$option_d" = true ]; then

						fileModTime=$(stat "$file" -c %Y)	  # Obtemos a data da última modificação do file em segundos desde 01/01/1970
						userDateInSeconds=$(date --date="$date" +%s)	# Usamos $userDateInSeconds para conter a data que o user inseriu, transformada em segundos desde 01/01/1970

						# Comparamo-la com a data inserida pelo user, também em segundos desde 01/01/1970 e, se for menor ou igual (data máxima da última modificação), 
						#então consideramos este ficheiro, caso contrário, descartamo-lo
						if (($fileModTime <= $userDateInSeconds)); then 
							# Comparamos o seu tamanho com o tamanho mínimo desejado, e se for maior, continuamos a considerá-lo, caso contrário, descartamo-lo
							if [ $file_size -ge $size ]; then
								# Se a condição acima for verdadeira, adicionamos o tamanho do ficheiro ao tamanho do diretório (tamanho a considerar no final)
								dir_size=$(($dir_size + $file_size))
							fi
						fi
					else
						if [ $file_size -ge $size ]; then
							# Se a condição acima for verdadeira e não tenha sido selecionada a opção "-d", adicionamos o tamanho do ficheiro ao tamanho 
							#do diretório (tamanho a considerar no final)
							dir_size=$(($dir_size + $file_size))
						fi
					fi
			
				done <<< "$files"	# Aqui, enquanto os ficheiros em $files não tiverem sido todos percorridos, mantém-se o loop em execução na variável $files
			fi
			# Por fim, imprimimos o tamanho final de cada subdiretório seguido do seu nome
			echo "$dir_size $subdir"
		else
			# Caso $subdir não tenha permissão para ser lido, apenas escrevemos NA seguido do seu nome, como pedido
			echo "NA $subdir"
		fi	
	done
}


#-------------------------------------------------------------------------------------------------------------------------------------#


# Processamento dos argumentos:

# Opções possíveis de serem fornecidas pelo user, para filtrar os resultados ou para configurar a ordem de como é apresentado no output

option_n=false # expressão regular para filtrar nome dos ficheiros
option_d=false # data máxima de modificação dos ficheiros
option_s=false # tamanho mínimo do ficheiro
option_r=false # ordenar por ordem inversa (ou seja, pela ordem correta do tamanho)
option_a=false # ordenar por nome
option_l=false # limitar o número de linhas da tabela


# Valores passados pelo user correspondentes às opções fornecidas:

file_pattern="" # opção -n (variável)
date=""         # opção -d (variável)
size="0"        # opção -s (variável)
limit=""        # opção -l (variável)
directories=()  # diretoria(s) a serem monitorizadas (array)
sort="-n -r"	# variável com as opções de ordenação default


# O comando 'getops' guarda as opções inseridas;
# Estas são especificadas na string abaixo '"n:d:s:ral:"';
# As letras significam as opções disponíveis para o utilizador;
# Os dois pontos a seguir a cada letra identificam as opções que necessitam de argumento;
# O argumento inserido pelo utilizador para cada uma das opções é guardado em $OPTARG ("option argument");
# As opções inseridas são então todas percorridas e é usado um case para verificar se 
#a opção armazenada na variável "$option" é uma das especificadas.

while getopts "n:d:s:ral:" option; do
	case $option in	
		n)	
			option_n=true   		
			file_pattern="$OPTARG"
		;;
		d)
			option_d=true
			
			# verificar se $OPTARG é uma data válida
			if is_date "$OPTARG"; then		
				date="$OPTARG"
			else
				echo "Error: A data introduzida é inválida."
				echo
			fi
		;;
		s)
			option_s=true
			
			# verificar se $OPTARG (tamanho mínimo do ficheiro) é número inteiro positivo 
			if is_integer_positive "$OPTARG"; then
				size="$OPTARG"
			else
				echo "Error: O número introduzido para o tamanho mínimo tem de ser inteiro positivo ou nulo."
				echo
			fi
		;;
		r)
			option_r=true
			sort="-n"
		;;
		a)
			option_a=true
			sort="-k 2" # -k serve para ordenar alfabeticamente, o 2 significa a segunda coluna, onde estão os nomes
		;;
		l)
			option_l=true
			
			# verificar se $OPTARG (número de linhas) é número inteiro positivo e maior que 0 
			if is_integer_positive "$OPTARG" && [ "$OPTARG" -gt 0 ]; then
				limit="$OPTARG"
			else
				echo "Error: O número limite de linhas introduzido tem de ser inteiro positivo."
				echo
			fi
		;;
	esac
done		


# Identificar os argumentos que são passados como diretórios
for option in "$@"; do
	if [ -d "$option" ]; then
		directories+=("$option")
	fi
done

if [ -z "$directories" ]; then
	directories+=$(pwd) # Caso o user não especifique nenhum diretório
fi

# Caso as opções -a e -r sejam introduzidas, ordenar por ordem alfabética inversamente
if [ "$option_r" = true ] && [ "$option_a" = true ]; then
	sort="-k 2r" 
fi


#-------------------------------------------------------------------------------------------------------------------------------------#


# Processamento do output

# Imprimirr o cabeçalho
print_head "$@"

# Para cada diretório, listar os tamanhos;
# É implementado um if para o caso do user introduzir um número de linhas a limitar;
# Caso option_l seja true é necessário agregar o comando head passando como argumento o número de linhas pretendido a limitar ($limit)
# Também é aqui usado o comando "2>/dev/null" para ignorar as mensagens de erros e mostrar a nossa personalizada

for dir in "${directories[@]}"; do
	print_output "$dir"
done | sort $sort | if [ "$option_l" = true ]; then head -n "$limit" 2>/dev/null; else cat; fi
echo ""

