# vim-translate-shell

## Introduction

Have you ever wanted to translate a word, sentence, paragraph, selection or
even whole file without beeing forced to copy - switch to browser - paste and
potentionally copy result and paste it back to the Vim? I bet so. Task is even
more annoying if your Vim distribution is not compiled with `+clipboard`
feature.

`vim-translate-shell` tries to make your life easier. This plugin does not do
the translation on its own, it is simple wrapper for `translate-shell`
application (https://github.com/soimort/translate-shell) that does whole job of
sending text to be translated to one of available engines, getting response and
presenting it to you.


## Example

The best way to show you how `vim-translate-shell` works is to do it on a
screencast.

https://github.com/user-attachments/assets/f0d3b4de-8133-48ad-93af-a0197204cfd3

Take a look at `doc/translate-shell.txt` to get detailed information about the
plugin.

## Installation

Using Vim's built-in package manager:

```
mkdir -p ~/.vim/pack/vim-translate-shell/start
cd ~/.vim/pack/vim-translate-shell/start
git clone https://github.com/apyszczuk/vim-translate-shell.git
vim -u NONE -c "helptags vim-translate-shell/doc" -c q
```


## Contribute

If you see a bug, or something that can be improved, or have an idea of a new
stuff that can be useful, just let me know via GitHub or email.


## License

Copyright © Artur Pyszczuk. Distributed under the same terms as Vim itself. See
`:help license`.
