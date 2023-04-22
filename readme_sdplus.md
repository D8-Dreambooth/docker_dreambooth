# digitalhigh/dreambooth

This is a Docker container for running Dreambooth, based on the PyTorch image from Runpod.

## Environment Variables

The following environment variables can be set when running the container:

- `UPDATE_EXTENSION`: Set to `true` to have the container update the Dreambooth extension on container start. Default is `false`.
- `UPDATE_WEBUI`: Set to `true` to update the Auto1111 WebUI on container start. Default is `false`.
- `PUBLIC_KEY`: Set to allow SSH access to the container. Runpod automatically sets this if configured in user settings.
- `JUPYTER_PASSWORD`: Set this to set the password for the Jupyter Notebook server. Default is no password.
- `API_KEY`: Set this to use a predefined API key, versus generating one.

The following environment variables are required to mount a Backblaze B2 bucket to the container:

- `B2_ACCOUNT_ID`: The Backblaze B2 account ID.
- `B2_APPLICATION_KEY`: The Backblaze B2 application key.
- `MOUNT_PATH`: The path to mount the Backblaze B2 bucket to.
- `MOUNT_POINT`: The path to mount the directory to.

## Ports

The following ports are exposed:

- `3000`: WebUI.
- `22`: SSH.

## Mount Points

The following directory can be mounted to a host directory:

- `/workspace`: This is the main working directory.

## Example Usage

Here's an example command to start the container:

```
docker run -p 3000:3000 -p 22:22 -v /path/to/host/folder:/workspace
-e B2_ACCOUNT_ID=<B2_ACCOUNT_ID>
-e B2_APPLICATION_KEY=<B2_APPLICATION_KEY>
-e MOUNT_PATH=<MOUNT_PATH>
-e MOUNT_POINT=<MOUNT_POINT>
-e UPDATE_EXTENSION=true
-e UPDATE_WEBUI=true
digitalhigh/dreambooth
```

Make sure to replace `<B2_ACCOUNT_ID>`, `<B2_APPLICATION_KEY>`, `<MOUNT_PATH>`, and `<MOUNT_POINT>` with the actual values for your Backblaze B2 bucket.

You can also set the `PUBLIC_KEY` environment variable to allow SSH access to the container.

Finally, you can set the `JUPYTER_PASSWORD` environment variable to set the password for the Jupyter Notebook server.
