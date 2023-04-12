@echo off
setlocal enabledelayedexpansion

set wheels_dir=".\wheels"

rem Define the URLs and their corresponding directories
set url_list=(
  "# ./wheels/torch1"
  "https://download.pytorch.org/whl/cu117/torch-1.13.1%2Bcu117-cp310-cp310-linux_x86_64.whl"
  "https://download.pytorch.org/whl/cu117/torchvision-0.14.1%2Bcu117-cp310-cp310-linux_x86_64.whl"
  "# ./wheels/torch2"
  "https://download.pytorch.org/whl/nightly/pytorch_triton-2.0.0%2B0d7e753227-cp310-cp310-linux_x86_64.whl"
  "https://download.pytorch.org/whl/nightly/cu118/torchvision-0.15.0.dev20230209%2Bcu118-cp310-cp310-linux_x86_64.whl"
  "https://download.pytorch.org/whl/nightly/cu118/torch-2.0.0.dev20230209%2Bcu118-cp310-cp310-linux_x86_64.whl"
  "https://github.com/ArrowM/xformers/releases/download/xformers-0.0.17+36e23c5.d20230209-cp310-cu118/xformers-0.0.17+36e23c5.d20230209-cp310-cp310-win_amd64.whl"
)

rem Loop through the URL list
for %%i in %url_list% do (
  set url=%%i

  rem Check if the URL is a directory or a file
  if "!url:~0,1!" == "#" (
    rem URL is a directory, create the directory if it doesn't exist
    set dir=!wheels_dir!\!url:~2!
    if not exist "!dir!" (
      mkdir "!dir!"
    )
  ) else (
    rem URL is a file, create the directory if it doesn't exist and download the file if it doesn't exist
    set filename=!url:*\=!
    set dir=!wheels_dir!\!filename!
    if not exist "!dir!" (
      mkdir "!dir!"
    )
    set file=!dir!\!filename!
    if not exist "!file!" (
      echo Downloading !url!...
      powershell -Command "(New-Object System.Net.WebClient).DownloadFile('!url!', '!file!')"
    )
  )
)

docker build --build-arg TORCH2=false --tag digitalhigh/dreambooth:latest .\docker_dreambooth --file .\docker_dreambooth\Dockerfile
docker push digitalhigh/dreambooth:latest
docker build --build-arg TORCH2=true --tag digitalhigh/dreambooth:torch2_latest .\docker_dreambooth --file .\docker_dreambooth\Dockerfile_torch2
docker push digitalhigh/dreambooth:torch2_latest
