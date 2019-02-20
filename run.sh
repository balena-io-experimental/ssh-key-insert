# This oneiner does the following:
# * takes UUIDs from the 'batch' file
# * in parallel runs the update logic on them, with parallelism defined by the '-P' setting
# * if there's a success logged for a UUID, nothing is run
# * if no success logged, then check if UUID exists first,
#   then connect to the device with balena ssh, pipe in the task script, and
#   save the log with the UUID prepended
cat batch | stdbuf -oL xargs -I{} -P 30 /bin/sh -c "grep -a -q '{} : DONE' sshkey.log || (balena device {} > /dev/null 2>&1 && cat add-ssh-key.sh | balena ssh {} -s | sed 's/^/{} : /' | tee --append sshkey.log)"
