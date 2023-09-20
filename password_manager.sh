#!/bin/bash

# 定数を定義
readonly ENC_FILE="password_lock.txt" # 暗号化した時のファイル名
readonly DEC_FILE="password.txt" # 復号化した時のファイル名

# 暗号化処理
function encrypt () {
  openssl enc -e -aes-256-cbc -salt -k $sslPassword -in $DEC_FILE -out $ENC_FILE 2> /dev/null
  rm $DEC_FILE
}

#復号化処理
function decrypt () {
  openssl enc -d -aes-256-cbc -salt -k $sslPassword -in $ENC_FILE -out $DEC_FILE 2> /dev/null
}

# opensslコマンドが使用できるかチェック
function check_openssl () {
  openssl version 1>/dev/null 2>&1
  if [ $? != 0 ]; then
    echo -e "...「openssl」がインストールされていません\n...パスワードマネージャを利用するには「openssl」をインストールしてください"
    exit
  fi
}
# ログイン処理
function login () {

  ## 初めてパスワードマネージャーを使用する場合
  if [ ! -e "$ENC_FILE" ]; then
    while :
    do
      while :
      do
        read -s -p "ログインパスワードを設定してください（非表示）:" sslPassword
        echo
        if [ -z "$sslPassword" ]; then
          echo "ログインパスワードが未入力です"
        else
          break
        fi
      done
      read -s -p "確認のためもう一度ログインパスワードを入力してください（非表示）:" confirmPassword
      echo
      if [ "$sslPassword" != "$confirmPassword" ]; then
        echo "入力したパスワードが異なっています"
      else
        echo "ログインパスワードの登録に成功しました"
        touch $DEC_FILE
        encrypt $sslPassword $DEC_FILE $ENC_FILE
        break
      fi
    done

  ## すでにパスワードが登録されている場合
  else
    while :
    do
      read -s -p "ログインパスワードを入力してください（非表示）:" sslPassword
      openssl enc -d -aes-256-cbc -salt -k $sslPassword -in $ENC_FILE 1>/dev/null 2>&1
      if [ $? != 0 ]; then
        echo
        echo "ログインパスワードが違います"
      else
        echo
        echo "ログインに成功しました"
        break
      fi
    done
  fi
}

# Add Passwordが選択されたときの処理
function add_password () {

  while :
  do
    read -p "サービス名を入力してください:" serviceName
    decrypt $sslPassword $ENC_FILE $DEC_FILE
    exists=`grep -x サービス名:$serviceName $DEC_FILE 2> /dev/null`
    if [ -z "$serviceName" ]; then
      echo "サービス名が未入力です"
    elif [ $exists ]; then
      echo "そのサービスはすでに登録されています"
    else
      encrypt $sslPassword $DEC_FILE $ENC_FILE
      break
    fi
    encrypt $sslPassword $DEC_FILE $ENC_FILE
  done

  while :
  do
    read -p "ユーザー名を入力してください:" userName
    if [ -z "$userName" ]; then
      echo "ユーザー名が未入力です"
    else
      break
    fi
  done

  while :
  do
  read -s -p "パスワードを入力してください（非表示）:" password
    if [ -z "$password" ]; then
      echo
      echo "パスワードが未入力です"
    else
      break
    fi
  done

  decrypt $sslPassword $ENC_FILE $DEC_FILE
  echo -e "サービス名:"$serviceName"\nユーザー名:"$userName"\nパスワード:"$password"\n" >> $DEC_FILE
  encrypt $sslPassword $DEC_FILE $ENC_FILE
  
  echo -e "\nパスワードの追加に成功しました\n"
}

# Get Passwordが選択されたときの処理
function get_password () {
    read -p "サービス名を入力してください:" serviceName
    decrypt $sslPassword $ENC_FILE $DEC_FILE
    result=`grep -A 2 -x サービス名:$serviceName $DEC_FILE 2> /dev/null`

    if [ -z "$serviceName" ]; then
      echo "サービス名が未入力です"
    elif [ ! "$result" ]; then
      echo -e "そのサービスは登録されていません。\n"
    else 
      echo "$result"
    fi
    encrypt $sslPassword $DEC_FILE $ENC_FILE
}

# メイン処理
echo "パスワードマネージャーへようこそ！"
check_openssl
login
while :
do
  read -p "次の選択肢から入力してください( Add Password / Get Password / Exit ):" selected

  case $selected in
    "Add Password") 
      add_password;;
    "Get Password") 
      get_password;;
    "Exit") 
      echo "Thank you!"
      break;;
    *) 
      echo -e "入力が間違っています。Add Password / Get Password / Exit から入力してください。\n";;
  esac

done