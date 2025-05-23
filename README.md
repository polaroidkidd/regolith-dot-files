# Oh-My-ZSH plugins

* z
* git
* ssh-agent
* sudo
* safe-paste
* nvm
* pnpm-shell-completion
* gcloud
* kubectl-autocomplete
* zsh-syntax-highlighting
* fast-syntax-highlighting
* zsh-autocomplete
* zsh-autosuggestions

Install Script:

```sh
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting && \
git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting && \
git clone --depth 1 -- https://github.com/marlonrichert/zsh-autocomplete.git $ZSH_CUSTOM/plugins/zsh-autocomplete && \
git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions && \
```
