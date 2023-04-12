# digitalhigh/dreambooth

### A handy-dandy container for running dreambooth.

## Env flags:

UPDATE_EXTENSION: Set to have the container update the dreambooth extension on container start.

UPDATE_WEBUI: Update the Auto1111 WebUI on container start.

PUBLIC_KEY: Set for openSSH access. Runpod automatically sets this if configured in user settings.

JUPYTER_PASSWORD: Erm...

API_KEY: Set this to use a predefined API KEY, versus generating one.


## Ports and stuff:

3000 - WebUI

22 - SSH

/workspace - Mount this.