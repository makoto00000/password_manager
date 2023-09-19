#!/bin/bash

# Add Passwordが選択されたときの処理
add_password () {
  read -p "サービス名を入力してください:" serviceName
  read -p "ユーザー名を入力してください:" userName
  read -p "パスワードを入力してください:" password
  echo -e "サービス名:"$serviceName"\nユーザー名:"$userName"\nパスワード:"$password"\n" >> password.txt
  echo -e "\nパスワードの追加は成功しました。"
}

# Get Passwordが選択されたときの処理
get_password () {
    read -p "サービス名を入力してください:" serviceName
    grep -A 2 -x サービス名:$serviceName password.txt 2> /dev/null
    if [ $? != 0 ]; then
      echo -e "そのサービスは登録されていません。\n"
    fi
}

# メイン処理
echo "パスワードマネージャーへようこそ！"
while :
do
  read -p "次の選択肢から入力してください(Add Password/Get Password/Exit):" selected

  case $selected in
    "Add Password") 
      add_password;;
    "Get Password") 
      get_password;;
    "Exit") 
      echo "Thank you!"
      break;;
    *) 
      echo -e "入力が間違えています。Add Password/Get Password/Exit から入力してください。\n";;
  esac

done