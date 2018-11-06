#!/usr/bin/env bash

brew install node

mkdir ~/.npm-global
ln -sfv "$DOTFILES_DIR/.npmrc" ~
