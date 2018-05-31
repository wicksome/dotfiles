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
1. java 1.8
1. Install [Homebrew](https://brew.sh/index_ko)
2. Install vcprompt
3. Install powerline font

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

# vim

## Installation

youcompleteme 설치

```sh
$ cd ~/.vim/plugged/youcompleteme
$ ./install.py --gocode-completer
$ ./install.py --tern-completer
```

# References

https://github.com/webpro/dotfiles

