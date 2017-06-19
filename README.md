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

- 폰트 설치
  - install powerline font

    ```bash
    $ git clone https://github.com/powerline/fonts.git
    ```

# 기타 설치해야할 것들

https://github.com/powerline/fonts
https://github.com/Swatto/td
https://github.com/junegunn/vim-plug


# vim

## Installation

```sh
alias vi='mvim -v'
alias vim='mvim -v'
```

youcompleteme 설치

```sh
$ cd ~/.vim/plugged/youcompleteme
$ ./install.py --gocode-completer
$ ./install.py --tern-completer
```

sss



# 참고

https://github.com/webpro/dotfiles

