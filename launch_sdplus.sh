#!/bin/bash
echo "SDPlus Container Started"
export PYTHONUNBUFFERED=1
source /workspace/stable-diffusion-plus/venv/bin/activate

cd /workspace/stable-diffusion-plus

if [[ "$UPDATE_WEBUI" == "true" ]]; then
  echo "Updating SD+"
  git fetch && git pull
fi

echo "Installing SD+ requirements"
pip install -r /workspace/stable-diffusion-plus/requirements.txt

# Install rclone (if not already installed)
if ! command -v rclone &>/dev/null; then
  echo "rclone not found, installing..."
  curl https://rclone.org/install.sh | sudo bash
fi

# Configure rclone for Backblaze B2 if environment variables are set
if [ -n "$B2_ACCOUNT_ID" ] && [ -n "$B2_APPLICATION_KEY" ] && [ -n "$MOUNT_PATH" ] && [ -n "$MOUNT_POINT" ]; then
  echo "Configuring rclone for Backblaze B2..."
  rclone config create b2 remote b2 \
    type b2 \
    account "$B2_ACCOUNT_ID" \
    key "$B2_APPLICATION_KEY"

  # Mount the Backblaze B2 bucket to a directory
  echo "Mounting Backblaze B2 bucket to directory..."
  rclone mount b2: "$MOUNT_PATH" \
    --allow-other \
    --dir-cache-time 1000h \
    --vfs-read-chunk-size 32M \
    --vfs-read-chunk-size-limit 1G \
    --buffer-size 1G \
    --umask 002 \
    --log-level INFO \
    --log-file /var/log/rclone.log &

  # Wait for mount to be available
  echo "Waiting for mount to be available..."
  while [[ ! -d "$MOUNT_PATH" ]]; do sleep 1; done

  # Mount the directory to the mount point
  echo "Mounting directory to mount point..."
  mount --bind "$MOUNT_PATH" "$MOUNT_POINT"
fi

echo "Launching relauncher..."
python launch.py &

if [[ -n $PUBLIC_KEY ]]; then
  mkdir -p ~/.ssh
  chmod 700 ~/.ssh
  cd ~/.ssh
  echo $PUBLIC_KEY >>authorized_keys
  chmod 700 -R ~/.ssh
  cd /
  service ssh start
  echo "SSH Service Started"
fi

sleep infinity
