#!/bin/bash

function livraisonListfile(){

installJobTalend  ${currentDir} "$jobName"
genereFichierLancement
archiveCurrentJob ${currentDir} "$jobName"

}

#********************************************
#check for the last instruction
#**********************************
function initialize(){
gv_scriptName=${0}
gv_step="Start execution fo script ${gv_scriptName}"
currentDir=`pwd`
APPL_PRODUCT=${HOME}/appl
JobDir=${APPL_PRODUCT}/jobTalend
JobContextDir=${JobDir}/JobContext
APPL_SCRIPT=${APPL_PRODUCT}/scripts
APPL_LOG_SCRIPTS=${APPL_PRODUCT}/exploitation
APPL_LIVRAISON=${HOME}/livraison
APPL_INSTALL=${APPL_LIVRAISON}/install
APPL_LOG_INSTALL=${APPL_INSTALL}/log
logDate=$(date +"%d%m%Y")
LOG=${APPL_LOG_INSTALL}/installation_"${logDate}.log"
rm -f ${LOG}
echo "Start Installation  ">${LOG}
}

#*****************************************************
#Function detarFile 
#FileName : The Full File path name
#RepDestination : Destination where to create tarfile
#*****************************************************
function exitError() 
{
    echo "=================================================" >>${LOG}
	echo  " Nom du Script ===> $gv_scriptName <=============" >>${LOG}
    echo  " Attention Erreur à l'étape Step = ${gv_step}   "  >>${LOG}
	echo  " " 
	echo  "=================================================" >>${LOG}
    exit 1
}
#********************************************
#check for the last instruction
#********************************************
function testLastCmd()
{
  if test $? -ne 0
  then 
    exitError
  fi
}

#*****************************************************
#Function copyFile 
#FileName : The Full File path name
#RepDestination : Destination where to create tarfile
#*****************************************************
copyShellFile(){
fullfile=${1}
Directory=${2}
fileName=$(basename $fullfile)
echo "copie file ${fileName} to ${Directory}" >>${LOG}
cp -f ${fullfile} ${Directory}  >> ${LOG}
testLastCmd

echo "Chmod 775 of file ${fileName} In ${Directory}" >>${LOG}
chmod 775 ${Directory}/${fileName}
testLastCmd
}
#*****************************************************
#Function archiveCurrentJob 
#FileName : The Full File path name
#RepDestination : Destination where to create tarfile
#*****************************************************
function archiveCurrentJob () {
dateJour=`date +"%d%m%Y%H%M%S" `
cp ${jobToInstall} ${APPL_LIVRAISON}/archive/
testLastCmd
mv ${APPL_LIVRAISON}/archive/${jobToInstall}  ${APPL_LIVRAISON}/archive/${jobName}"_"${dateJour}".zip"
testLastCmd
}
#*****************************************************
#Function installJobTalend 
#FileName : The Full File path name
#RepDestination : Destination where to create tarfile
#*****************************************************
function installJobTalend () {

echo "jobName = ${jobName}" >>$LOG
echo "JobDirectory = ${JobDirectory}" >>$LOG
echo "find ${JobDir}/${jobName} -name *.sh" >>$LOG

unzip -o ${JobDirectory}/${jobToInstall} -d ${JobDir}/${jobName} >>$LOG
testLastCmd
listFile=`find ${JobDir}/${jobName}/ -name "*.sh"`
for file in ${listFile}
do
echo "chmod sur le fichier ${file}" >>$LOG
chmod 775 ${file}
testLastCmd
done
#chmod -R 775 ${JobDir}/${jobName}/*.sh
testLastCmd
}

#*********************************************************/
#Function genere Fichier de Lancement
#Description :  
#*********************************************************/
genereFichierLancement () {
scriptLancement=${APPL_SCRIPT}/${jobName}".sh"
touch ${scriptLancement}
# echo ". ~/.profile">${scriptLancement}
# echo "source DirConf.sh">>${scriptLancement}
# echo "dateLancement=\`date +\"%d%m%y%H%M%S\"\`">>${scriptLancement}
# echo "source GlbTools.sh">>${scriptLancement}
cat  ${JobDirectory}/scriptLancementPart1.param >${scriptLancement}

echo "export LOG=\"\${APPL_LOG_SCRIPTS}/${jobName}_\${dateLancement}.log\"">>${scriptLancement}
echo "   ">>${scriptLancement}
echo "executeJob \"${JobDir}/${jobName}\" \"${jobName}\"">>${scriptLancement}
echo "   ">>${scriptLancement}
echo "testLastCmd ">>${scriptLancement}
chmod 775 ${scriptLancement}
}

#*********************************************************/
#Function main
#Description :  Fonction principal d'installation des job
#*********************************************************/

function main(){
initialize
JobDirectory=${currentDir}
echo jobToInstall=${jobToInstall} >>$LOG
echo jobName=${jobName} >>$LOG
echo JobDirectory=${JobDirectory} >>$LOG
livraisonListfile
}

#********************************************
#   argument line handling
#********************************************
error=no
if [ $# -ne 1 ]; then
    error=yes
fi

if [ "x$error" = "xyes" ]; then
    echo "$0:Error: invalid argument line"
    echo "$0:Usage: $0 <Job Name>"
    echo "Where <Job Name> is Extracted from Talend"
    echo "must be (*.zip)"
    
    exit 1
fi

export jobToInstall=${1}
export jobName=`basename ${jobToInstall} .zip`

main

echo "End of installation ">>${LOG}
cat ${LOG}
exit 0