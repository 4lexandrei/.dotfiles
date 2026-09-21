# 4lexandrei's dotfiles

This repository contains my personal dotfiles.

![pacman-gruvbox](assets/dotfiles.png)

## My setup

**Desktop Environment:** [`Hyprland`](.config/hypr/README.md)  
**Shell:** [`bash`](bashrc.d/README.md)  
**Terminal:** `kitty`  
**Terminal Multiplexer:** [`tmux`](.config/tmux/README.md)  
**Text Editor:** `neovim`  
**Colorscheme:** `Gruvbox Material`  
**Font:** `JetbrainsMono Nerd Font`

## Installation

> [!WARNING]
> Please ensure to clone this repository inside `~/.dotfiles` otherwise setup scripts might not work

Clone repository:

```
git clone https://github.com/4lexandrei/.dotfiles.git ~/.dotfiles
```

For the latest (unstable) version, clone the `dev` branch:

```
git clone -b dev https://github.com/4lexandrei/.dotfiles.git ~/.dotfiles
```

## Usage

Run dotfiles setup command

```
~/.dotfiles/bin/dotfiles
```

---

## Windows Support

For the latest (unstable) version, clone the `dev` branch:

```
git clone -b dev https://github.com/4lexandrei/dotfiles.git
```

For Windows users, open Powershell as Administrator and run the following snippet to create symlinks

```powershell
New-Item -ItemType SymbolicLink -Path "link" -Target "path_to_link"
```

Examples:  
SymbolicLink for lazyvim

```powershell
New-Item -ItemType SymbolicLink -Path "C:\Users\username\AppData\Local\nvim" -Target "C:\Users\username\.dotfiles\.config\nvim\lazyvim"
```

SymbolicLink for .bashrc

```powershell
New-Item -ItemType SymbolicLink -Path "C:\Users\username\.bashrc" -Target "C:\Users\username\.dotfiles\.bashrc"
```
