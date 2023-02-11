import os, time

n = 0
gradio_auth = os.getenv('GRADIO_AUTH', None)
torch2 = os.getenv('TORCH2', None)
while True:
    print('Relauncher: Launching...')
    if n > 0:
        print(f'\tRelaunch count: {n}')
    launch_string = "python webui.py --port 3000 --xformers --ckpt-dir /workspace/models/ --listen --enable-insecure-extension-access --no-half"
    if gradio_auth:
        launch_string += " --gradio-auth " + gradio_auth
    if torch2 == "true":
        launch_string += " --torch2"
    os.system(launch_string)
    print('Relauncher: Process is ending. Relaunching in 2s...')
    n += 1
    time.sleep(2)
