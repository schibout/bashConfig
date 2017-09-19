#!/bin/bash
####################################################################################################
#                                                                                                  #
# Bibliotheque de fonctions communes aux traitements Analyse Impact		                           #
# Auteur: SCT (Sopra Group)	                                                                       #
# Date de creation              : 06/05/2016                                                       #
# Date de derniere modification : 06/05/2016                                                       #
# Version: 1.0                                                                                     #
#                                                                                                  #
####################################################################################################
#===================================================================================================
# Historique des modifications
#---------------------------------------------------------------------------------------------------
#Auteur SCHIBOUT  (Sopra group)  : Migration vers Neo4j 2.2		
#===================================================================================================
#///////////////////////////////////////////////////////////////////////////////////////////////////
#//////////////////////////// Fonctions d'initialisations des batchs ///////////////////////////////
#///////////////////////////////////////////////////////////////////////////////////////////////////

#---------------------------------------------------------------------------------------------------
# Fonction de definition des constantes de codes retour et de formatage des messages
#---------------------------------------------------------------------------------------------------

#---------------------------------------------------------------------------------------------------
# Fonction de log
#---------------------------------------------------------------------------------------------------

log(){
echo "${1}" >> ${LOG}
}

# Useful unarchiver!
function extract () {
        if [ -f $1 ] ; then
                case $1 in
                        *.tar.bz2)        tar xjf $1                ;;
                        *.tar.gz)        tar xzf $1                ;;
                        *.bz2)                bunzip2 $1                ;;
                        *.rar)                rar x $1                ;;
                        *.gz)                gunzip $1                ;;
                        *.tar)                tar xf $1                ;;
                        *.tbz2)                tar xjf $1                ;;
                        *.tgz)                tar xzf $1                ;;
                        *.zip)                unzip $1                ;;
                        *.Z)                uncompress $1        ;;
                        *)                        log "'$1' cannot be extracted via extract()" ;;
                esac
        else
                log "'$1' is not a valid file"
        fi
}

#---------------------------------------------------------------------------------------------------
# Fonction d'affichage de l'aide
# (affichage de toutes les lignes du sources commencant par #~)
#---------------------------------------------------------------------------------------------------

executeJob()
{
	directory=${1}
	jobName=${2}
	#executableFileName=${directory}/${jobName}/${jobName}"_run.sh"
	executableFileName=`find ${directory} -name "${jobName}*.sh"`
	export gv_scriptName=${executableFileName}
	gv_step="Start execution fo Talend Job  ${jobName} in directory ${directory} with Commande ${executableFileName}"
	
	header ${directory} ${jobName}
	
	if [ -d ${directory} ] ; then
	  if [ -r ${executableFileName} ] ; then
		
		chmod  775 ${executableFileName} >> ${LOG} 
		${executableFileName} >> ${LOG}  2>&1
		retour=$?
		if [ "$retour" -ne 0 ];
		then
		    log "																 "  
			log "PROJET  ${directory} -Job Nmae : ${jobName} NOK"
			exitWithError
		else
			log " job -Job Nmae : ${jobName} in  ${directory} finished with success"
		fi
	  else
   	     	log "Talend: File Name ${executableFileName} Not Exists  NOK"
			exitWithError
	  fi		
	else
	  	    log "Talend: Directory Name ${directory} Not Exists  NOK"
			exitWithError
	fi		
}

#
#
#
header()
{
directory=${1}
jobName=${2}
log   "		"
log   "       "
log " Start execution of job -Job Nmae : ${jobName} in  ${directory}"
log " 															" 
log "				 " 
}
#---------------------------------------------------------------------------------------------------
# Fonction d'affichage de l'aide
# (affichage de toutes les lignes du sources commencant par #~)
#---------------------------------------------------------------------------------------------------

listFile(){
currentDirectory=$1
if  [ -z ${currentDirectory} ]	; then
currentDirectory="."
fi
echo "  "  >> ${LOG}
echo "File Date time    		  Size    File Name">>${LOG}
find ${currentDirectory} -type f -print0 | xargs -0 stat -c "%y %s %n"| sed 's/\(:[0-9]\{2\}\)\.[0-9]* /\1 /' >>${LOG}
echo "  "  >> ${LOG}
}

#---------------------------------------------------------------------------------------------------
# Fonction d'affichage de l'aide
# (affichage de toutes les lignes du sources commencant par #~)
#---------------------------------------------------------------------------------------------------
Usage()
{
 grep "^#~" $1 | cut -c 3- ;
}
#---------------------------------------------
#
#
#
#---------------------------------------------
executeCmde(){
	cmd=$@
	if [ -n "$cmd" ]; then
	 $cmd
	 retCode=$?
	 if test $retCode -ne 0
      then
        log "================================================="
		log " Nom du Script ===> $gv_scriptName      "
		log " Error at  Step = ${gv_step}   " 
		log " Command Line = ${cmd}"
		log " Retrun code = ${retCode}"
		log "================================================="
		exit 2
	 fi
	else
		log " No Thing To Execute "
	fi
}
#---------------------------------------------------------------------------------------------------
# Fonction d'initialisation de la log globale du traitement (si existe deja,purge)
# Parametre : 1- Nom du fichier de log
# Rqe: Initialise la variable globale FileLogGlobal
#---------------------------------------------------------------------------------------------------
InitFileLogGlobal()
{
   NomLog="$1"
   logDate=$(date +"%Y-%m-%d")
   FileLogGlobal="${APPL_LOG}/importer/"$1"_"${logDate}".log"
   RemoveFile "${FileLogGlobal}"
}
#********************************************
# Fonction de Sortie d'erreur 
#********************************************
exitWithError() 
{
    #mailList="schibout-prestataire@vente-privee.com;fkovacs@vente-privee.com"   
    mailList="schibout-prestataire@vente-privee.com"   
    log "================================================="
	log " Nom du Script ===> $gv_scriptName      "
    log " Error at  Step = ${gv_step}   " 
	log " "
	log "================================================="
    mailx -s "Rapport d'erreur  " $mailList <$LOG
	exit 2
}
#********************************************
# Fonction de Sortie d'erreur 
#********************************************
SortieError()
{
  if test $? -ne 0
  then 
	log "=========== CRTICAL ERROR =	==================="
	log " Nom du Script ===> $gv_scriptName 		       "
    log " Error at  Step = ${gv_step}   				   " 
	log " 												   "
	log "================================================="
     mailx -s "Rapport d'erreur  " $mailList <$LOG
	exit 2
  fi	
}
#********************************************
# Fonction de Sortie d'erreur 
#********************************************
SortieTraitement() 
{
 	log "=========== CRTICAL ERROR =	==================="
	log " Nom du Script ===> $gv_scriptName 		       "
    log " Error at  Step = ${gv_step}   				   " 
	log " 												   "
	log "================================================="
	exit 2	
}
#********************************************
#check for the last instruction
#********************************************
testLastCmd()
{
  if test $? -ne 0
  then 
    exitWithError
  fi
}
#********************************************
#check for the last instruction
#********************************************

RemoveFile() {
	FILE_TO_REMOVE=$1
	if [ -r ${FILE_TO_REMOVE} ] 
	then
	 ls -1 ${FILE_TO_REMOVE} 1>/dev/null 2>&1
      if [ $? -eq 0 ]
      then
         rm -f ${FILE_TO_REMOVE}
	  else
         log "	can not remove file ${FILE_TO_REMOVE} "
         exitWithError		 
      fi
	fi;
}
#---------------------------------------------------------------------------------------------------
# Fonction de suppression d'un fichier s'il existe
# Parametre : 1- Path du fichier a supprimer
#---------------------------------------------------------------------------------------------------
RemoveFileInDirecotry()
{
   Directory="$1"
   log "Directory = $Directory"
   listFiles=`ls ${Directory}`
   for RemoveFileCur in  $(listFiles)
   do
      RemoveFile ${RemoveFileCur} 
   done
}
#*****************************************************
# detarFile 
#FileName : The Full File path name
#RepDestination : Destination where to create tarfile
#*****************************************************
detarFile(){
FileName="${1}"
RepDestination="${2}"
if [ -d ${RepDestination} ]; then
	if [ -r ${FileName} ]; then
		echo " tar -zxvf ${FileName} -C ${RepDestination}" 
		testLastCmd
	else
		log "${FileName} not found  "
	fi	
else
	    log "${RepDestination} dosn't exist  "  
fi
}
#*************************************************************
# archiveFiles
#Directory want to archive
#Destination Directory
#Pattern  : Match Pattern ("RM21","RM71"...etc) 
#**************************************************************
archiveFiles(){
DirTop=${1}
RepDestination=${2}
matchPattern=${3}
if [ -d $DirTop ]; then
  if [ -d ${RepDestination} ]; then
    for SubDirectory in ${DirTop}/${matchPattern}
	do
	if [ -d ${SubDirectory} ] ; then
	     echo "SubDirectory = ${SubDirectory} "
		 echo "tar -vcvf ${SubDirectory}.tar ${matchPattern}" 
		 testLastCmd
		 echo "gzip ${SubDirectory}.tar"
		 testLastCmd
		 echo "cp -f ${SubDirectory}.tar.gz  ${RepDestination}"
		 testLastCmd
	else
	     echo "${SubDirectory} Is Not Directory "
    fi	
	done
  else
    log " : ${RepDestination} does not exists  " 
  fi   
else
    log " : ${DirTop}  does not exists  " 
fi
}
#*************************************************************
# Clean Directory
#Used to CleanUp a Directory and SubDirectories
#**************************************************************
 CleanDirecory(){
DirTop=${1}
if [ -d $DirTop ]; then
    for SubDirectory in ${DirTop}/*
	do
	 rm -Rf ${SubDirectory}
	 testLastCmd
	done
else
    log " : ${DirTop}  does not exists  " 
fi
}
#*****************************************************
# detarFileWithRename 
#FileName : The Full File path name
#RepDestination : Destination where to create tarfile
#Pattern  : Match Pattern ("RM21","rm80"...etc) 
#newName : The target name to the detared file
#*****************************************************
detarFileWithRename(){
FileName="${1}"
RepDestination="${2}"
matchPattern="${3}"
newName="${4}"
if [ -d ${RepDestination} ]; then
	if [ -r ${FileName} ]; then
		echo " tar -zxvf ${FileName} -C ${RepDestination}" 
		testLastCmd
		echo "mv ${RepDestination}/${matchPattern} ${RepDestination}/${newName}" 
	else
		log "${FileName} not found  "
	fi	
else
	    log "${RepDestination} dosn't exist  "  
fi
}
#*****************************************************
# detarCsvFile 
#FileName : The Full File path name
#RepDestination : Destination where to create tarfile
#*****************************************************
 detarCsvFile(){
FileName="${1}"
RepDestination="${2}"
if [ -d ${RepDestination} ]; then
	if [ -r ${FileName} ]; then
		echo " tar -zxvf ${FileName} *.csv -C ${RepDestination}" 
		testLastCmd
	else
		log "${FileName} not found  "
	fi	
else
	    log "${RepDestination} dosn't exist  "  
fi
}