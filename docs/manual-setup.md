# Manual setup

Do these after `make` has installed the baseline. None of this is automated.

1. **Git identity.** Copy `git/.gitconfig.local.example` to `~/.gitconfig.local`. Set `user.name` and `user.email`.
2. **Optional local Bash configuration.** If this machine needs extra shell config, copy `shell/bash/.bashrc.local.example` to `~/.bashrc.local`.
3. **GitHub authentication.** Run `gh auth login`.
4. **Docker Desktop first run.** Open Docker Desktop once, complete first-run setup, then verify with `docker version`.
5. **Optional cloud/data-platform authentication.** Only when needed:

   ```bash
   aws configure sso
   databricks auth login --host <workspace-url>
   astro login
   ```

   `astro login` is only needed when deploying to Astronomer.
6. **Rectangle Accessibility permission.** System Settings → Privacy & Security → Accessibility, then enable Rectangle.
