## Add SSH keys to BalenaOS devices

Starting from Balena OS [v2.20.0](https://github.com/balena-os/meta-balena/blob/master/CHANGELOG.md#v2200)
it is possible to provide the operating system with custom SSH keys, that are loaded
at boot time into the system, and allow users to connect to even production versions
of the operating system with their own key. It is accomplished by adding an extra
entry to the `config.json`, following the structure as shown in the
[documentation](https://github.com/balena-os/meta-balena#sshkeys).

You can either add those structures to the `config.json` before you provision
a device, or modify that file of an existing device. This repository presents
tooling for doing the latter option in a safe, and parallel manner, using the
balena CLI to connect to devices and run an updater script on them.

### Requirements

* [balena CLI](https://github.com/balena-io/balena-cli/) version above v9.15.0 installed
  (so that the `--noninteractive` option is available in `balena ssh`)
* Linux operating system

### Usage

* Modify the `add-ssh-keys.sh` file, to add your SSH key to the `SSHKEY` variable
  as the example in that file shows
* Create a file called `batch` in this same folder, add listing all the device UUIDs
  that you want to modify, one UUID per line.
* The default parallelism is 10 devices at the same time, you can modify that by
  altering the `run.sh` file, and chaning the integer in the `-P 10` option to the
  desired value.
* Make sure that you are logged in with the right user (for example by `balena whoami`)
* Run the batch update by executing `./run.sh`. You will start to see the logs as the
  key is added to the different device. The log is also saved in the `sshkey.log` file.
* The scripts are set up such, that:
  * keys are added to the `config.json`, no existing key is removed from it
  * if there's log in `sshkey.log` that shows a device / particular UUID already
    successfully modified, it will skipped if `./run.sh` is rerun

You can check the results in the log, afterwards, for example showing all the
successful updates with:
```
cat sshkey.log | grep DONE
```
or all the failures:
```
cat sshkey.log | grep FAIL
```

**Also note**, that just after this update the ssh keys don't take effect
just yet, rather the device needs to be rebooted, so that the
appropriate OS service will place the files to the right places.
