 let
   nixpkgs = fetchTarball "https://github.com/NixOS/nixpkgs/tarball/nixos-24.05";
   pkgs = import nixpkgs { config = {}; overlays = []; };
 in

 pkgs.mkShellNoCC {
   packages = with pkgs; [
    gcc
    gnumake
    zlib
    libffi
    readline
    bzip2
    openssl
    ncurses
    pyenv
    curl
    openssl
    pyenv
    git
    docker
	sqlite
	xz
	wget
	copier
	bash-completion
	pre-commit
   ];

   NAME = "nix-data-lake";

   shellHook = ''
     echo "Sit tight, we're initializing $NAME ...";

     echo "~~~~~ Pyenv global version default to 3.11.9 ~~~~~"";
     pyenv global 3.11.9

     echo "~~~~~ Pyenv-virtualenv plugin installation ~~~~~"";
     git clone https://github.com/pyenv/pyenv-virtualenv.git \
        $(pyenv root)/plugins/pyenv-virtualenv;

     echo "~~~~~ Git command and branch autocompletion ~~~~~"";
     curl -o ~/.git-completion.bash \
 		https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash
	 curl -o ~/.git-prompt.sh \
		https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh

     echo "~~~~~ Bash shell restart w/ profile, prompt, aliases, and more! ~~~~~"";
     bash;
   '';
}