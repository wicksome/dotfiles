# .files

> These are my dotfiles. Take anything you want, but at your own risk.

![local_prompt](https://user-images.githubusercontent.com/5036939/27002254-f4435aba-4e17-11e7-8237-10a7f5bdccc7.png)

## Package overview

- Core
  - Bash
  - Homebrew, homebrew-cask
  - Node.js + npm
- Dev
- macOS: Hammerspoon, Mackup, Quick Look plugins
- macOS apps

## Installation

1. Install apps
  - [Homebrew](https://brew.sh/index_ko)
  - [vcprompt](https://github.com/djl/vcprompt)
  - [powerline font](https://github.com/powerline/fonts.git)
  - [java](https://stackoverflow.com/questions/24342886/how-to-install-java-8-on-mac)
2. `git clone https://github.com/wicksome/dotfiles.git`
3. Setting other apps config
  - atom: [sync-settings](https://atom.io/packages/sync-settings)
  - iterm2

## Requirements


- vcprompt 설치
  - `https://github.com/djl/vcprompt`에서 vcprompt 받고 bin에 이동

    ```bash
    $ $PATH
    -bash: /usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin: No such file or directory
    $ mv ./vcprompt /usr/local/bin/
    ```
    - 참고사이트
        - http://blog.outsider.ne.kr/737
        - https://github.com/insanehong/bash_env
        
# vim

## Installation

youcompleteme 설치

```sh
$ cd ~/.vim/plugged/youcompleteme
$ ./install.py --gocode-completer
$ ./install.py --tern-completer
```

# References

- https://github.com/webpro/dotfiles

