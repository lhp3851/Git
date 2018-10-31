# Git
Git 常用操作及原理

1、初始化本地git

    git init

2、配置用户名

    git config --global user.name "<your nickName>"

3、配置邮箱

    git config --global user.email "<your email address>"

4、查看仓库状态

    git status

  Tips：支持中文文件名

    git config --global core.quotepath false

5、提交本地仓库

    git add .
    git commit -m"【Git】[Git 常用操作及原理]"

6、关联远程仓库

    git remote add origin <your git repository address>

7、保持Github 同步

    git pull

  Tips 1：
  There is no tracking information for the current branch.
  Please specify which branch you want to merge with.
  See git-pull(1) for details.

    git pull <remote> <branch>

  If you wish to set tracking information for this branch you can do so with:

    git branch --set-upstream-to=origin/<branch> master

  解决方式：

    git branch --set-upstream-to=origin/master master

  Tips 2：
    refusing to merge unrelated histories

  解决方式：

    git pull --allow-unrelated-histories

8、推送到远程仓库

    git push -u origin master

  Tips：记得添加公钥，增加写权限


#### * 先从GitHub上初始化仓库，再clone到本地应该不会这么麻烦
