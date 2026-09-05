# Manual setup

Do these after completing the automated `make` targets. None of this is automated.

1. **Git identity.** If `~/.gitconfig.local` does not exist, copy `git/.gitconfig.local.example`. Otherwise edit the existing file and preserve its current contents. Ensure `user.name` and `user.email` are configured.
2. **Optional local Bash configuration.** If `~/.bashrc.local` does not exist, copy `shell/bash/.bashrc.local.example`. Otherwise edit the existing file and preserve its current contents.
3. **GitHub authentication.** Run `gh auth login`.
4. **Docker Desktop first run.** Open Docker Desktop once, complete first-run setup, then verify with `docker version`.
5. **Optional cloud/data-platform authentication.** Only when needed:

   ```bash
   aws configure sso
   databricks auth login --host https://your-workspace.cloud.databricks.com
   astro login
   ```

   `astro login` is only needed when deploying to Astronomer.
6. **Rectangle Accessibility permission.** System Settings → Privacy & Security → Accessibility, then enable Rectangle.
