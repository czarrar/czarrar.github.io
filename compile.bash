#!/usr/bin/env bash

echo "Compiling"
echo "ruhoh compile"
ruhoh compile

echo
echo "Configuring github"
echo "cd compiled"
cd compiled

echo "git init ."
git init .

echo "git add ."
git add .

echo "git commit -m 'update blog'"
git commit -m 'update blog'

echo "git remote add origin https://github.com/czarrar/czarrar.github.io.git"
git remote add origin https://github.com/czarrar/czarrar.github.io.git

echo "git remote -v"
git remote -v

echo "git push origin master --force"
git push origin master --force
