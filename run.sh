# This oneliner does the following:
# * takes UUIDs from the 'batch' file
# * in parallel runs the update logic on them, with parallelism defined by the '-P' setting
# * connect to the device with balena ssh, pipe in the task script, and
#   save the log with the UUID prepended
cat batch | stdbuf -oL xargs -I{} -P 10 /bin/sh -c "grep -a -q '{} : DONE' sshkey.log || (cat add-ssh-key.sh | balena ssh {} | sed 's/^/{} : /' | tee --append sshkey.log)"
