#!/bin/bash

echo -e "\033[0;32mDeploying updates to GitHub...\033[0m"

# compress png images
# pngquant --ext .png --force --speed 1 content/img/*.png

# Build the project.
hugo

# Go To Public folder
cd public
# Add changes to git.
git add .

# Commit changes.
msg=":pencil2:"
if [ $# -eq 1 ]
  then msg="$1"
fi
git commit -m "$msg"

# Push source and build repos.
git push origin master

# Come Back up to the Project Root
cd ..

# Push source code:  https://github.com/yag-ays/yag-ays.github.io.source
git add .
git commit -m "$msg"
git push -u origin master
