## Config files

There are different config files for different technologies. The hook [`get_shared_config`](../pre_commit_hooks/) will detect the technology of the repo and grab the respective config files.

This makes it easier to keep them updated in case something changes

- [tf](./tf/) - specific config files for terraform projects
- [tfm](./tf/tfm/) - specific config files for terraform  module projects (e.g. different `PRCHECKLIST`)
...


