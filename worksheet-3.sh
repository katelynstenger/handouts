# configure git
git config --global user.name katelynstenger
git config --global user.email katelynstenger@gmail.com
git commit --no-edit --amend --reset-author

# Link your local repository to the origin repository on GitHub, by
# copying the code shown on your GitHub repo under the heading:
# "…or push an existing repository from the command line"

git remote add origin https://github.com/katelynstenger/handouts.git
git push -u origin master
