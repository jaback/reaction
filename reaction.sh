#!/bin/bash

# Reaction
# Jandir Back

# Imprimir um ponto 
# Parâmetros:
#    $1 - Posição X no tabuleiro
#    $2 - Posição Y no tabuleiro
#    $3 - Cor do ponto
function print_dot {
   echo  "\033[4$3;34m\033[$1;$2H \033[1B"
}

# Imprimir um fundo negro para o tabuleiro
# Parâmetros:
#    $1 - Tamanho do tabuleiro
function print_table {
   for i in `seq $1`; do
      for j in `seq $1`; do
         print_dot $i $j 0
      done
   done
}

# Calcular porcentagem
# Parâmetros:
#    $1 - Valor A
#    $2 - Valor B
# Retorno:
#    Porcentagem do valor B em relação ao valor A
function calculate_percentage {
   return $((100 * $2 / $1))
}

# Imprime contadores
# Parâmetros:
#    $1 - Contador da cor amarela
#    $2 - Contador da cor azul
#    $3 - Contador da cor roxa
#    $4 - Posição X no tabuleiro
#    $5 - Número mínimo de ciclos
function print_result {
   times=$(($1 + $2 + $3))
   calculate_percentage $times $1
   echo "\033[0;0m\033[$4;0HYellow:\t$?% $1  "
   calculate_percentage $times $2
   echo "\033[0;0m\033[$(($4 + 1));0HBlue:\t$?% $2  "
   calculate_percentage $times $3
   echo "\033[0;0m\033[$(($4 + 2));0HPurple:\t$?% $3  "
}

# Remove ponto
# Parâmetros:
#    $1 - Tamanho do tabuleiro
function remove_dot {
  re_x=$(($RANDOM % $1))
  re_y=$(($RANDOM % $1))
  print_dot $re_x $re_y 0
  explose 0 0 $re_x $re_y $1
}

# Explode o ponto 
# Parâmetros:
#    $1 - Cor do ponto anterior
#    $2 - Cor do ponto atual
#    $3 - Posição X
#    $4 - Posição Y
#    $5 - Tamanho do tabuleiro 
function explose {
   ex_pre_color=$1
   ex_color=$2
   ex_x=$3
   ex_y=$4
   ex_max=$5
   if [ $ex_pre_color -eq $ex_color ]; then
       ex_pre_y=$(($ex_y - 1))
       ex_pos_y=$(($ex_y + 1))
       ex_pre_x=$(($ex_x - 1))
       ex_pos_x=$(($ex_x + 1))
       if [ $ex_pre_x -gt 0 ]; then
          print_dot $ex_pre_x $ex_y $ex_color
       fi
       if [ $ex_pos_x -lt $ex_max ]; then
          print_dot $ex_pos_x $ex_y $ex_color
       fi
       if [ $ex_pre_y -gt 0 ]; then
          print_dot $ex_x $ex_pre_y $ex_color
          if [ $ex_pre_x -gt 0 ]; then
             print_dot $ex_pre_x $ex_pre_y $ex_color
          fi
          if [ $ex_pos_x -lt $ex_max ]; then
             print_dot $ex_pos_x $ex_pre_y $ex_color
          fi
       fi
       if [ $ex_pos_y -lt $ex_max ]; then
          print_dot $ex_x $ex_pos_y $ex_color
          if [ $ex_pre_x -gt 0 ]; then
             print_dot $ex_pre_x $ex_pos_y $ex_color
          fi
          if [ $ex_pos_x -lt $ex_max ]; then
             print_dot $ex_pos_x $ex_pos_y $ex_color
          fi
       fi
    fi
}

# Função principal
# Parâmetros:
#    $1 - Tamanho máximo do tabuleiro (Opcional)
#    $2 - Número mínimo de ciclos (Opcional)
clear

# Definir o tamanho máximo do tabuleiro e o número mínimo de ciclos
default_max_size=20
default_max_times=15
if [ $# -eq 0 ]; then
   max=$default_max_size
   max_times=$default_max_times
else
   max=$1
   if [ $# -eq 2 ]; then
      max_times=$2
   else
      max_times=$default_max_times
   fi
fi

# Inicializar contadores
count_color_yellow=0
count_color_blue=0
count_color_purple=0
pre_color=0

# Inicializar tabuleiro
print_table $max
let max++

while true; do 

   # Escolher cor: amarela (3), azul (4) ou roxa (5)
   color=$(($(($RANDOM % 3)) + 3)) 

   # Atualizar contador
   case $color in
      3) let count_color_yellow++ ; if [ $pre_color -eq $color ]; then count_color_yellow=$(($count_color_yellow + 8)); fi ;;
      4) let count_color_blue++ ; if [ $pre_color -eq $color ]; then count_color_blue=$(($count_color_blue + 8)); fi ;;
      5) let count_color_purple++ ; if [ $pre_color -eq $color ]; then count_color_purple=$(($count_color_purple + 8)); fi ;;
   esac

   # Remover (apagar) ponto(s) aleatório(s)
   remove_dot $max 

   # Imprimir ponto de cor e posição aleatória
   x=$(($RANDOM % $max))
   y=$(($RANDOM % $max))
   print_dot $x $y $color

   # Caso a cor do ponto atual for a mesma do ponto anterior: 
   #    Imprimir pontos marginais ao ponto atual
   explose $pre_color $color $x $y $max

   # Imprimir contadores
   print_result $count_color_yellow $count_color_blue $count_color_purple $max $max_times

   # Verificar número de ciclos
   if [ $count_color_yellow -eq $max_times ]; then
      break;
   fi
   if [ $count_color_blue -eq $max_times ]; then
      break;
   fi
   if [ $count_color_purple -eq $max_times ]; then
      break;
   fi
   if [ $count_color_yellow -gt $max_times ]; then
      if [ $count_color_blue -gt $max_times ]; then
         if [ $count_color_purple -gt $max_times ]; then
            echo "∞"
            break;
         fi
      fi
   fi

   sleep 0.01
   pre_color=$color
done
