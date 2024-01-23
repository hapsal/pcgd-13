# Project Course on Game Development 2024 - Group 13


### Git workflow example:   

#### Start with master:

git checkout main

#### Get latest changes:  

git pull --rebase

#### Make own feature-branch:

git checkout -b feature/new-feature

...Do stuff and things

#### Time to add feature to git:

git add -A

git commit -m "feat: new feature x"

git fetch origin

git rebase origin/main

git push --set-upstream origin feature/new-feature
