# 적용하기 전 준비 

1. `https://github.com/djl/vcprompt`에서 vcprompt 받고 bin에 이동
  
    ```bash
    $ $PATH
    -bash: /usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin: No such file or directory
    $ mv ./vcprompt /usr/local/bin/
    ```
  
    - 참고사이트
        - http://blog.outsider.ne.kr/737
        - https://github.com/insanehong/bash_env
  
2 install powerline font

    ```bash
    $ git clone https://github.com/powerline/fonts.git
    ```
    
    - 더 확인해볼 구분자
        - https://github.com/ryanoasis/powerline-extra-symbols




- install autojump
    
    ```bash
    $ brew install autojump
    ```

    - 터미널 zsh쉘
        - https://nolboo.github.io/blog/2015/08/21/oh-my-zsh/


## 이슈

- 프롬프트에서 한줄 이상 넘어갈 때 개행이 안되고 중복되는 것
- 이전 명령어 쓰려고 방향키 누르다 보면 한글자 안사라지는 점
- 좀 더 나한테 맞게 커스터마이징할 것
