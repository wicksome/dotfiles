# Bash Config

## Custom function/alias

***.alias***

|               command               |          description           | example |
| ----------------------------------- | ------------------------------ | ------- |
| `..`                                | `cd ..`                        |         |
| `...`                               | `cd ../../`                    |         |
| `l [file ...]`                      | `ls -l`                        |         |
| `ll [file ...]`                     | `ls -al`                       |         |
| `lsd [file ...]`                    | show only directory list       |         |
| `ip`                                | show current ip list           |         |
| `stime`                             | show boot-time                 |         |
| <code>st [file &#124; dir]</code>   | open sublime text              |         |
| <code>atom [file &#124; dir]</code> | open atom                      |         |
| <code>vs [file &#124; dir]</code>   | open vs code                   |         |
| <code>md [file &#124; dir]</code>   | open macdown                   |         |
| `hosts`                             | show enable hosts              |         |
| `http-status [status-code]`         | open document http-status-code |         |

***.function***

|       command       |        description         |
| ------------------- | -------------------------- |
| `calc [expression]` | [Deprecated] calculater    |
| `weather`           | show weather of sungnam-si |

***.function_fs***

|      command      |                  description                  |
| ----------------- | --------------------------------------------- |
| `ff [file-name]`  | Search for files exactly matching             |
| `fff [file-name]` | Search for files that contain file name       |
| `fd [dir-name]`   | Search for directories exactly matching       |
| `ffd [dir-name]`  | Search for directories that contain file name |

***.function_network***

|      command      |               description                |
| ----------------- | ---------------------------------------- |
| `hostname2ip`     | get ip of hostname                       |
| `transfer [file]` | easy file sharing - https://transfer.sh/ |


## Issue

### prompt 입력이 긴 경우 오버랩되는 버그

`//[` 추가

```sh
PS1='\\[\e[0;32m\u $ '
```

- [link](http://askubuntu.com/a/24416/444925)
