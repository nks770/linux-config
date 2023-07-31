#!/bin/bash

git remote remove origin
git remote add origin https://${1}@github.com/nks770/linux-config.git
git push --set-upstream origin main
git status
