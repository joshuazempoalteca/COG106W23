#!/bin/bash

git pull origin main
date > version 
git add version
git commit -m"updated version file"
git push origin main
