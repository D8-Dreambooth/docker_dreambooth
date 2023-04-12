import os
import time

gradio_auth = os.getenv('GRADIO_AUTH', None)

while True:
    print('Relauncher: Launching...')

    # Kill existing process
    for line in os.popen("ps aux | grep 'webui.py' | grep -v grep"):
        fields = line.split()
        pid = fields[1]
        print(f"Relauncher: Killing process {pid}...")
        os.kill(int(pid), 9)

    # Launch new process
    launch_string = "python webui.py --port 3000 --api --ckpt-dir /workspace/models/ --listen --enable-insecure-extension-access --no-half --xformers"
    if gradio_auth:
        launch_string += " --gradio-auth " + gradio_auth
    os.system(launch_string)

    print('Relauncher: Process is ending. Relaunching in 2s...')
    time.sleep(2)
