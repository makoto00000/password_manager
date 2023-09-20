#!/bin/bash

# Add Passwordが選択されたときの処理
add_password () {
  while :
  do
    read -p "サービス名を入力してください:" serviceName
    exists=`grep -x サービス名:$serviceName password.txt 2> /dev/null`
    if [ -z "$serviceName" ]; then
      echo "サービス名が未入力です"
    elif [ "$exists" ]; then
      echo "そのサービスはすでに登録されています"
    else
      break
    fi
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

  echo -e "サービス名:"$serviceName"\nユーザー名:"$userName"\nパスワード:"$password"\n" >> password.txt
  echo -e "\nパスワードの追加に成功しました。\n"
}

# Get Passwordが選択されたときの処理
get_password () {
    read -p "サービス名を入力してください:" serviceName
    result=`grep -A 2 -x サービス名:$serviceName password.txt 2> /dev/null`

    if [ -z "$serviceName" ]; then
      echo "サービス名が未入力です"
    elif [ ! "$result" ]; then
      echo -e "そのサービスは登録されていません。\n"
    else 
      echo "$result"
    fi
}

# メイン処理
echo "パスワードマネージャーへようこそ！"
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