## Shared git-hooks

1. Define a directory

   ```shell
   HOOKS="$HOME/.config/git/hooks"
   ```

2. Create directory

   ```shell
   mkdir $HOOKS
   ```

3. Clone the repo to `$HOME/.config/git/hooks`

   ```shell
   git clone git@gitlab.com/papanito/git-hooks.git $HOOKS
   ```

4. Configure git to use the hooks

   ```shell
   git config --global core.hooksPath $HOOKS
   ```
