#!/bin/sh
if [[ -n 'which brew' ]]; then
  if [[ -n 'which appledoc' ]]; then

    echo  -n '输入公司名称';
    read company_name;

    echo -n '输入公司标识';
    read company_id;

    echo -n '输入工程名字';
    read project_name;

    echo -n '是否需要生成苹果文档';
    read isCreateDoc;

    if [ ${isCreateDoc} == 'yes' ] ;then
      echo '生成xcode 文档';
      appledoc --output ./Doc --project-name ${project_name} --project-company ${project-company} --company-id ${company_id} . ;
      cat ./Doc/docset-installed.txt
    else
      echo '生成html文档';
      appledoc --no-create-docset  --output ./Doc --project-name ${project_name} --project-company ${project-company} --company-id ${company_id} . ;
    fi
    echo "当前路径为 :"
    pwd;

  else
    brew install appledoc;
  fi
else
  echo '请先安装 brew'
  exit
fi
