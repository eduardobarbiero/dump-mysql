#!/bin/sh

# Script para backup de base de dados MySql envio de email sobre logs utilizando mailutils

# Parâmetros do sistema
DATE=`date +%Y-%m-%d`
DB_NAME="empresa_db"
DB_USER="root"
DB_PASS="root"
DB_PARAM='--add-drop-table --add-locks --extended-insert --single-transaction -quick'
MYSQLDUMP=/usr/bin/mysqldump
BACKUP_DIR=/backup/mysql
BACKUP_NAME=mysql-$DATE.sql
BACKUP_TAR=mysql-$DATE.tar
MAILTO="eduardo@abc.co"

# Limpar arquivo de logs
cat /dev/null > "$BACKUP_DIR/database.log"

# Criar novo arquivo de logs
touch "$BACKUP_DIR/database.log"

# Gerando arquivo sql
echo "-- Gerando Backup da base de dados $DB_NAME em $BACKUP_DIR/$BACKUP_NAME ..."
$MYSQLDUMP $DB_NAME $DB_PARAM -u $DB_USER -p $DB_PASS > $BACKUP_DIR/$BACKUP_NAME

# Verificando se o processo acima foi concluído com exito
if [ "$?" -eq 0 ]
then
  # Compactando arquivo em TAR
  echo "-- Compactando arquivo em tar ..." >> "$BACKUP_DIR/database.log"
  tar -cf $BACKUP_DIR/$BACKUP_TAR -C $BACKUP_DIR $BACKUP_NAME

  # Compactando arquivo em BZIP2
  echo "-- Compactando arquivo em bzip2 ..." >> "$BACKUP_DIR/database.log"
  bzip2 $BACKUP_DIR/$BACKUP_TAR

  # Excluindo arquivos desnecessarios
  echo "-- Excluindo arquivos desnecessarios ..." >> "$BACKUP_DIR/database.log"
  rm -rf $BACKUP_DIR/$BACKUP_NAME

  # Enviar email de sucesso
  mail -s "ATENÇÃO: Backup de $DB_NAME concluido com sucesso!" $MAILTO < "$BACKUP_DIR/database.log"
  exit
else
  # Enviar email de falha
  mail -s "ATENÇÃO: Houve um problema ao fazer Backup da base de dados $DB_NAME! " $MAILTO < "$BACKUP_DIR/database.log"
  exit
fi
