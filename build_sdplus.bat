@echo off
setlocal enabledelayedexpansion


docker build --tag digitalhigh/sdplus:latest .\ --file .\Dockerfile_sdplus
docker push digitalhigh/sdplus:latest

