#!/bin/bash
#
# Extrai e instala fonts a partir de arquivos compactados
#
# Entra no diretorio especificado, copia todas os arquivos de font compactados para um diretorio
# temporario, descompacta e instala
#
# Version: 0.1 - 23/05/2022 - levantamento de requisitos
# Version: 0.2 - 24/05/2022 - Implementação da função de instalação por nome de arquivo
# Version: 0.3 - 25/05/2002 - Implementação da funcção de instalação a partir de diretórios
#
# Status: levantamento de requisitos
#

#
# FICA COMENTADO DURANTE O PERIODO DE DESENVOLVIMENTO
#
if [ $UID -ne 0 ]; then
   echo "You must be root"
   exit 1
   
   elif [ ! $# -ge 1 ]; then
      echo "Sorry, missing parameter"
      echo -e "Usage: $(basename $0) ${HELP}"
      exit 1
fi

#if [ ! $# -ge 1 ]; then
#      echo "Sorry, missing parameter"
#      echo -e "Usage: $(basename $0) ${HELP}"
#      exit 1
#fi


# Help
HELP=' <option> <fqdn>
Create a new domain to be hosted\n
options
\t-h,\t--help\t\tshow this message
\t-i,\t--install\tinstala o arquivo de font indicado
\t\t\t\t(path completo)
\t-d,\t--dir\t\tinstala arquivos do diretorio informado
\t-V\t--version\tshow version'

#Verificando os diretórios de fonts
test -d /usr/share/fonts/truetype || exit 1
test -d /usr/share/fonts/opentype || exit 1

#Preparacao do ambiente
export PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin
export TTFdir=/usr/share/fonts/truetype 
export TTCdir=/usr/share/fonts/opentype


#Descompactar arquivos
#unzip -x aardvark_cafe.zip -d /tmp/instafont-tmp/



function show_version(){
	
	echo -e "Name:\t$(basename $0)\nVersion: $(grep ^#\ Version: $0 | tail -n 1| cut -d ' ' -f3)\n"
	
}

#Descompactar arquivos e Instalar as fonts

function install(){
	
	echo "Instalando a fonte solicitada: ${FILEFONT}"

	sleep 1
	
	tempdir=/tmp/instalaFont-${RANDOM}
	mkdir ${tempdir}
	unzip -xL ${FILEFONT} -d ${tempdir} >/dev/null 2>&1
	FONTS+=$(find ${tempdir} -type f -name "*.tt?")
	
	while read -e font; do 

		ext=$(echo "$font" | rev | cut -d '.' -f 1 | rev)
					
		if [ "$ext" == "ttf" ]; then

			mv "$font" ${TTFdir} || exit 1
			
			elif [[ "$ext" == "ttc" ] || [ "$ext" == "otf" ]]; then

				mv "$font" ${TTCdir}  || exit 1
				
			else
			
				MENSAGEM="Extensão de font desconhecida em $font\n"
				RETVAL=1
		fi
		RETVAL=$(( $RETVAL+$? ))
		
	done <<< ${FONTS[@]}
	
	RETVAL=$(( $RETVAL+$? ))
	
	#Limpeza da bagunca
	if [ $RETVAL -eq 0 ]; then
	
		echo "entrei aqui"
		MENSAGEM=${MENSAGEM}"Fonte ${FILEFONT} instalada com sucesso.\n"
		rm -rf ${tempdir} || MENSAGEM=${MENSAGEM}"Não foi possível remover o diretório temporário.\n"
		
	else
	
		MENSAGEM=${MENSAGEM}"Ops! Algo correu mal!\nRetval: ${RETVAL}"
		exit 1
		
	fi
	FONTS=''
	
}

case $1 in

	-V|--version)
		show_version
		;;
		
	-h|--help)
		echo -e "Usage: $(basename $0) ${HELP}"
		;;
		
	-i|--install)
		if [ $# -eq '2' ]; then
			FILEFONT=$2
			install 
			 
		else
			MENSAGEM=${MENSAGEM}"Nao foi possivel instalar a font indicada. A quantidade de parametros nao eh valida.\n"
			RETVAL=1
			
		fi
			echo -e "${MENSAGEM}\nRetval: ${RETVAL}"		
		;;
	
	-d|--dir)
		if [ $# -eq '2' ]; then
			# executar a função install em loop dentro do diretório indicado
			echo "Esta função ainda não está implementada."
			
			DIRFONT=$2
						
			for FILEFONT in $(find ${DIRFONT} -type f); do
			
					ext=$(echo "${FILEFONT}" | rev | cut -d '.' -f 1 | rev | tr [:upper:] [:lower:])
					
					if [ "$ext" == "zip" ]; then
					
						echo "Executando a funcao install em ${FILEFONT}"
						install  || exit 1
												
					elif [ "$ext" == "ttf" ]; then

						echo "Movendo ${FILEFONT} para ${TTFdir}"
						mv "${FILEFONT}" ${TTFdir}  || exit 1
						
					elif [[ "$ext" == "ttc" ] || [ "$ext" == "otf" ]]; then
						
						echo "Movendo ${FILEFONT} para ${TTFdir}"
						mv "${FILEFONT}" ${TTCdir} || exit 1
				
					else
			
						MENSAGEM="Extensão de font desconhecida em ${FILEFONT}\n"
						RETVAL=1
						
					fi
					RETVAL=$(( $RETVAL+$? ))
				
			done
		fi
		;;

	*)
		echo -e "Usage: $(basename $0) ${HELP}"
        ;;
		
esac
