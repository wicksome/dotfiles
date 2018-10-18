# .files

> These are my dotfiles. Take anything you want, but at your own risk.

![local_prompt](https://user-images.githubusercontent.com/5036939/27002254-f4435aba-4e17-11e7-8237-10a7f5bdccc7.png)


## Install(NEW)

1. install [chrome](https://www.google.com/chrome/)
2. init [macos](https://github.com/wicksome/dotfiles/tree/master/macos) env
3. install [iterm](https://www.iterm2.com)
```bash
cd
mkdir workspace
cd workspace
git clone https://github.com/wicksome/dotfiles
cd dotfiles
./install.sh
```
4. install [zsh](https://ohmyz.sh)
5. isntall 1password(appstore)
6. install mindnode(appstore)
7. install [notion](https://www.notion.so/desktop)

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
        ```
        $ $PATH # check path
        -bash: /usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin: No such file or directory
        $ mv ./vcprompt /usr/local/bin/
        ```
    - [powerline font](https://github.com/powerline/fonts.git)
    - [java](https://stackoverflow.com/questions/24342886/how-to-install-java-8-on-mac)
2. Install dotfiles
    ```
    $ git clone https://github.com/wicksome/dotfiles.git
    $ cd dotfiles && ./install.sh
    ```
3. Setting other apps config
    - atom: [sync-settings](https://atom.io/packages/sync-settings)
    - iterm2
    - intelliJ
4. get mackup directory in dropbox and restore mackup
    ```
    $ mackup restore
    ```

## References

- https://github.com/webpro/dotfiles
- http://blog.outsider.ne.kr/737
- https://github.com/insanehong/bash_env
