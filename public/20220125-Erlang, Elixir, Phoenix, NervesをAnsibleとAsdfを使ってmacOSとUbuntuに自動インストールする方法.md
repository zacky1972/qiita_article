---
title: 'Erlang, Elixir, Phoenix, NervesをAnsibleとAsdfを使ってmacOSとUbuntuに自動インストールする方法'
tags:
  - Erlang
  - Elixir
  - Ansible
private: false
updated_at: '2022-01-25T08:20:20+09:00'
id: 38a9ebb53bbc406fabb7
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
Erlang, Elixir, Phoenix, Nervesを1台のmacOSまたはUbuntuのPCにAsdfを使ってインストールするとしたときに，たとえば[「M1 Mac への ElixirとErlang インストール2021年12月決定版」](https://qiita.com/zacky1972/items/c94baef2ee9379c21fa1)のような記事にしたがって，手でインストールすることと思います。しかし，もし2台以上のPCにインストールするとしたら，自動化したくなるものと思います。Ansibleはそのような方法です。

この記事では，Erlang, Elixir, Phoenix, NervesをmacOSとUbuntuのPC上にAnsibleとAsdfを用いて自動的にインストールする方法をご紹介します。

この記事の英訳版は["Install Erlang, Elixir, Phoenix, and Nerves automatically to machines on macOS and Ubuntu by Ansible and Asdf"](https://dev.to/zacky1972/install-erlang-elixir-phoenix-and-nerves-automatically-to-machines-on-macos-and-ubuntu-by-ansible-and-asdf-2olc)です。

# この記事の前提

1台のホストと1台以上のターゲットがあるとします。この時，Ansibleをホストにインストール済みであることを前提とします。ターゲットはmacOSまたはUbuntuであるとします。また，macOSのターゲットにはHomebrewをインストール済みであることを前提とします。さらに，全てのターゲットに公開鍵で`ssh`を用いてログインできるものとし，全てのターゲットで同一のパスワードを用いて`sudo`で管理者権限になれるものとします。そして，ターゲットのホスト名は `target1, target2, ..., target9` であるものとします。

# inventory.yml

ターゲットの情報と共通変数を `inventory/inventory.yml` に記述します。

```yaml:inventory/inventory.yml
all:
  hosts:
    target[1:9]:
  vars:
    asdf: v0.8.1
    erlang: latest
    elixir: latest
    phoenix: latest
    nerves: latest
```

`target[1:9]`は`target1, target2, ..., target9`を表しており，必要に応じて変更することができます。Asdf, Erlang, Elixir, Phoenix, Nervesのバージョンをそれぞれ指定することができます。この場合，Asdfのバージョンは`v0.8.1`であり，Asdfの他のバージョンは最新版であることを表しています。Erlang, Elixir, Phoenix, Nervesのバージョンをそれ以外の古いバージョンに指定することもできます。

とくに `localhost` にインストールする場合には次のようにします。

```yaml:inventory/localhost_inventory.yml
all:
  hosts:
    localhost:
      ansible_host: "127.0.0.1"
  vars:
    asdf: v0.8.1
    erlang: latest
    elixir: latest
    phoenix: latest
    nerves: latest
```

もし `localhost`にインストールする場合，`ssh`で`localhost`にログインできるように設定する必要があります。

# ansible.cfg

ワーニングを抑制するために，次のように `ansible.cfg` を記述することができます。

```ansible.cfg
[defaults]
interpreter_python=/usr/bin/python3
```

# タスク

再利用性のために，Ansibleタスクを部品として記述することができます。

## UbuntuにAsdfをインストールする

```yaml:tasks/0010_install_asdf_linux.yml
---
- block:
  - name: Install dependencies of asdf
    become: true
    apt:
      update_cache: yes
      cache_valid_time: 86400 # 1day
      name:
        - curl
        - git
      state: latest
  - name: Install asdf
    git:
      repo: https://github.com/asdf-vm/asdf.git
      dest: "{{ ansible_user_dir }}/.asdf"
      depth: 1
      version: "{{ asdf | quote }}"
    register: result
  - name: asdf update
    shell: "bash -lc 'cd {{ ansible_user_dir }}/.asdf && git pull'"
    ignore_errors: yes
    when: result is failed
  - name: set env vars
    lineinfile:
      dest: "{{ shrc }}"
      state: present
      line: "{{ item.line }}"
    with_items:
    - line: ". $HOME/.asdf/completions/asdf.{{ sh }}"
      regexp: '^ \. \$HOME/\.asdf/completions/asdf\.{{ sh }}'
    - line: '. $HOME/.asdf/asdf.sh'
      regexp: '^ \. \$HOME/\.asdf/asdf\.sh'
  when: ansible_system == 'Linux' and (ansible_distribution == 'Ubuntu' or ansible_distribution == 'Debian')
  vars:
    - shrc: "{{ ansible_user_dir | quote }}/.{{ ansible_user_shell | basename | quote }}rc"
    - sh: "{{ ansible_user_shell | basename | quote }}"
```

## masOSにAsdfをインストールする

```yaml:tasks/0010_install_asdf_macos.yml
---
- block:
  - name: install asdf by Homebrew
    community.general.homebrew:
      update_homebrew: true
      name:
        - asdf
  - name: set env vars (bash)
    lineinfile:
      dest: "{{ shprofile }}"
      state: present
      line: "{{ item.line }}"
    with_items:
    - line: ".  $(brew --prefix asdf)/etc/bash_completion.d/asdf.bash"
      regexp: '^ \. \$(brew --prefix asdf)/etc/bash_completion\.d/asdf\.bash'
    - line: '. $(brew --prefix asdf)/libexec/asdf.sh'
      regexp: '^ \. \$(brew --prefix asdf)/libexec/asdf\.sh'
    when: sh == 'bash'
  - name: set env vars (zsh)
    lineinfile:
      dest: "{{ shrc }}"
      state: present
      line: "{{ item.line }}"
    with_items:
    - line: ". $(brew --prefix)/share/zsh/site-functions"
      regexp: '^ \. \$(brew --prefix)/share/zsh/site-functions'
    - line: '. $(brew --prefix asdf)/libexec/asdf.sh'
      regexp: '^ \. \$(brew --prefix asdf)/libexec/asdf\.sh'
    when: sh == 'zsh'
  when: ansible_system == 'Darwin'
  vars:
    - shprofile: "{{ ansible_user_dir }}/.{{ ansible_user_shell | basename | regex_replace('$', '_') | regex_replace('zsh_', 'z') }}profile"
    - shrc: "{{ ansible_user_dir }}/.{{ ansible_user_shell | basename }}rc"
    - sh: "{{ ansible_user_shell | basename | quote }}"
```

## UbuntuにErlangの前提ライブラリをインストールする

```yaml:tasks/0011_install_erlang_prerequisite_linux.yml
---
- block:
  - name: install prerequisite libraries for erlang 
    become: true
    apt:
      update_cache: yes
      cache_valid_time: 86400 # 1day
      state: latest
      name:
      - build-essential
      - autoconf
      - m4
      - libncurses5-dev
      - libwxgtk3.0-gtk3-dev
      - libgl1-mesa-dev
      - libglu1-mesa-dev
      - libpng-dev
      - libssh-dev
      - unixodbc-dev
      - xsltproc
      - fop
      - libxml2-utils
      - libncurses-dev
      - openjdk-11-jdk
  when: ansible_system == 'Linux' and (ansible_distribution == 'Ubuntu' or ansible_distribution == 'Debian')
```

## masOSにErlangの前提ライブラリをインストールする

```yaml:tasks/0011_install_erlang_prerequisite_macos.yml
---
- block:
  - name: install prerequisite libraries for erlang 
    community.general.homebrew:
      update_homebrew: true
      name:
        - autoconf
        - openssl@1.1
        - openssl@3
        - wxwidgets
        - libxslt
        - fop
        - openjdk
  when: ansible_system == 'Darwin'
```

## UbuntuにNervesの前提ライブラリをインストールする

```yaml:tasks/0013_install_nerves_prerequisite_linux.yml
---
- block:
  - name: install prerequisite libraries for nerves
    become: true
    apt:
      update_cache: yes
      cache_valid_time: 86400 # 1day
      state: latest
      name:
      - automake
      - autoconf
      - git
      - squashfs-tools
      - ssh-askpass
      - pkg-config
      - curl
      - libssl-dev
      - libncurses5-dev
      - bc
      - m4
      - unzip
      - cmake
      - python
  when: ansible_system == 'Linux' and (ansible_distribution == 'Ubuntu' or ansible_distribution == 'Debian')
```

## macOSにNervesの前提ライブラリをインストールする

```yaml:tasks/0013_install_nerves_prerequisite_macos.yml
---
- block:
  - name: install prerequisite libraries for nerves 
    community.general.homebrew:
      update_homebrew: true
      name:
        - fwup 
        - squashfs
        - coreutils
        - xz
        - pkg-config
  when: ansible_system == 'Darwin'
```


## Erlang プラグインをインストールする

```yaml:tasks/0021_install_erlang_plugin.yml
---
- block:
  - name: sh env
    ansible.builtin.shell:
    args:
      cmd: "{{ shenv_cmd }}"
      chdir: '{{ ansible_user_dir }}/'
    register: shenv
  - name: asdf plugin add erlang
    ansible.builtin.shell: |
      {{ source }} 
      asdf plugin add erlang
    args:
      executable: '{{ ansible_user_shell }}'
    register: result
    failed_when: result.rc != 0 and result.stderr | regex_search('(Plugin named .* already added)') == '' 
    vars: 
      source: "{{ shenv.stdout_lines | map('regex_replace', '(^)', '. ') | join('\n') }}"
  vars:
    - asdfsh: "{{ ansible_user_dir | quote }}/.asdf/asdf.sh"
    - profile: "{{ ansible_user_dir | quote }}/.profile"
    - shprofile: "{{ ansible_user_dir }}/.{{ ansible_user_shell | basename | regex_replace('$', '_') | regex_replace('zsh_', 'z') }}profile"
    - shrc: "{{ ansible_user_dir | quote }}/.{{ ansible_user_shell | basename  | quote }}rc"
    - shenv_cmd: "if [ -e {{ asdfsh }} ]; then echo '{{ asdfsh }}'; fi; if [ -e {{ shprofile }} ]; then echo '{{ shprofile }}'; fi; if [ -e {{ profile }} ]; then echo '{{ profile }}'; fi; if [ -e {{ shrc }} ]; then echo '{{ shrc }}'; fi"
```

## Elixirプラグインをインストールする

```yaml:tasks/0022_install_elixir_plugin.yml
---
- block:
  - name: sh env
    ansible.builtin.shell:
    args:
      cmd: "{{ shenv_cmd }}"
      chdir: '{{ ansible_user_dir }}/'
    register: shenv
  - name: asdf plugin add elixir
    ansible.builtin.shell: |
      {{ source }} 
      asdf plugin add elixir
    args:
      executable: '{{ ansible_user_shell }}'
    register: result
    failed_when: result.rc != 0 and result.stderr | regex_search('(Plugin named .* already added)') == '' 
    vars: 
      source: "{{ shenv.stdout_lines | map('regex_replace', '(^)', '. ') | join('\n') }}"
  vars:
    - asdfsh: "{{ ansible_user_dir | quote }}/.asdf/asdf.sh"
    - profile: "{{ ansible_user_dir }}/.profile"
    - shprofile: "{{ ansible_user_dir }}/.{{ ansible_user_shell | basename | regex_replace('$', '_') | regex_replace('zsh_', 'z') }}profile"
    - shrc: "{{ ansible_user_dir }}/.{{ ansible_user_shell | basename }}rc"
    - shenv_cmd: "if [ -e {{ asdfsh }} ]; then echo '{{ asdfsh }}'; fi; if [ -e {{ shprofile }} ]; then echo '{{ shprofile }}'; fi; if [ -e {{ profile }} ]; then echo '{{ profile }}'; fi; if [ -e {{ shrc }} ]; then echo '{{ shrc }}'; fi"
```

## Erlang をインストールする

```yaml:tasks/0101_install_erlang.yml
---
- block:
  - name: sh env
    ansible.builtin.shell:
    args:
      cmd: "{{ shenv_cmd }}"
      chdir: '{{ ansible_user_dir }}/'
    register: shenv
  - name: asdf install erlang (for Linux)
    ansible.builtin.shell: |
      {{ source }} 
      asdf install erlang {{ erlang | quote }}
    args:
      executable: '{{ ansible_user_shell }}'
    register: result
    when: ansible_system == 'Linux'
    vars: 
      source: "{{ shenv.stdout_lines | map('regex_replace', '(^)', '. ') | join('\n') }}"
  - name: show result
    debug:
      var: result
  - name: asdf install erlang (macOS OTP version 24.1.x or earlier)
    ansible.builtin.shell: |
      {{ source }} 
      {{ install_erlang_ssl_1_1 }}
    args:
      executable: '{{ ansible_user_shell }}'
    register: result
    when: (erlang != 'latest' and erlang is version_compare('24.2', '<')) and ansible_system == 'Darwin'
    vars: 
      source: "{{ shenv.stdout_lines | map('regex_replace', '(^)', '. ') | join('\n') }}"
  - name: show result
    debug:
      var: result
    when: (erlang != 'latest' and erlang is version_compare('24.2', '<')) and ansible_system == 'Darwin'
  - name: asdf install erlang (macOS OTP 24.2 or later)
    ansible.builtin.shell: |
      {{ source }} 
      {{ install_erlang_ssl_3 }}
    args:
      executable: '{{ ansible_user_shell }}'
    register: result
    when: (erlang == 'latest' or (erlang is version_compare('24.2', '>='))) and ansible_system == 'Darwin'
    vars: 
      source: "{{ shenv.stdout_lines | map('regex_replace', '(^)', '. ') | join('\n') }}"
  - name: show result
    debug:
      var: result
    when: (erlang == 'latest' or (erlang is version_compare('24.2', '>='))) and ansible_system == 'Darwin'
  - name: asdf global erlang
    ansible.builtin.shell: |
      {{ source }} 
      asdf global erlang {{ erlang | quote }}
    args:
      executable: '{{ ansible_user_shell }}'
    vars: 
      source: "{{ shenv.stdout_lines | map('regex_replace', '(^)', '. ') | join('\n') }}"
  vars:
    - asdfsh: "{{ ansible_user_dir | quote }}/.asdf/asdf.sh"
    - profile: "{{ ansible_user_dir }}/.profile"
    - shprofile: "{{ ansible_user_dir }}/.{{ ansible_user_shell | basename | regex_replace('$', '_') | regex_replace('zsh_', 'z') }}profile"
    - shrc: "{{ ansible_user_dir }}/.{{ ansible_user_shell | basename }}rc"
    - shenv_cmd: "if [ -e {{ asdfsh }} ]; then echo '{{ asdfsh }}'; fi; if [ -e {{ shprofile }} ]; then echo '{{ shprofile }}'; fi; if [ -e {{ profile }} ]; then echo '{{ profile }}'; fi; if [ -e {{ shrc }} ]; then echo '{{ shrc }}'; fi"
    - install_erlang_ssl_1_1: "KERL_CONFIGURE_OPTIONS=\"--with-ssl=$(brew --prefix openssl@1.1) --with-odbc=$(brew --prefix unixodbc)\" CC=\"/usr/bin/gcc -I$(brew --prefix unixodbc)/include\" LDFLAGS=-L$(brew --prefix unixodbc)/lib asdf install erlang {{ erlang | quote }}"
    - install_erlang_ssl_3: "KERL_CONFIGURE_OPTIONS=\"--with-ssl=$(brew --prefix openssl@3) --with-odbc=$(brew --prefix unixodbc)\" CC=\"/usr/bin/gcc -I$(brew --prefix unixodbc)/include\" LDFLAGS=-L$(brew --prefix unixodbc)/lib asdf install erlang {{ erlang | quote }}"
```

## Elixirをインストールする

```yaml:tasks/0102_install_elixir.yml
---
- block:
  - name: sh env
    ansible.builtin.shell:
    args:
      cmd: "{{ shenv_cmd }}"
      chdir: '{{ ansible_user_dir }}/'
    register: shenv
  - name: asdf install elixir
    ansible.builtin.shell: |
      {{ source }}
      asdf install elixir {{ elixir | quote }}
    args:
      executable: '{{ ansible_user_shell }}'
    register: result
    vars: 
      source: "{{ shenv.stdout_lines | map('regex_replace', '(^)', '. ') | join('\n') }}"
  - name: show result
    debug:
      var: result
  - name: asdf install elixir
    ansible.builtin.shell: |
      {{ source }}
      asdf global elixir {{ elixir | quote }}
    args:
      executable: '{{ ansible_user_shell }}'
    vars: 
      source: "{{ shenv.stdout_lines | map('regex_replace', '(^)', '. ') | join('\n') }}"
  vars:
    - asdfsh: "{{ ansible_user_dir | quote }}/.asdf/asdf.sh"
    - profile: "{{ ansible_user_dir }}/.profile"
    - shprofile: "{{ ansible_user_dir }}/.{{ ansible_user_shell | basename | regex_replace('$', '_') | regex_replace('zsh_', 'z') }}profile"
    - shrc: "{{ ansible_user_dir }}/.{{ ansible_user_shell | basename }}rc"
    - shenv_cmd: "if [ -e {{ asdfsh }} ]; then echo '{{ asdfsh }}'; fi; if [ -e {{ shprofile }} ]; then echo '{{ shprofile }}'; fi; if [ -e {{ profile }} ]; then echo '{{ profile }}'; fi; if [ -e {{ shrc }} ]; then echo '{{ shrc }}'; fi"
```

## Phoenixをインストールする

```yaml:tasks/0201_install_phoenix.yml
-
- block:
  - name: sh env
    ansible.builtin.shell:
    args:
      cmd: "{{ shenv_cmd }}"
      chdir: '{{ ansible_user_dir }}/'
    register: shenv
  - name: install prerequisite
    ansible.builtin.shell: |
      {{ source }}
      mix local.rebar --force
      mix local.hex --force
    args:
      executable: '{{ ansible_user_shell }}'
    register: result
    vars: 
      source: "{{ shenv.stdout_lines | map('regex_replace', '(^)', '. ') | join('\n') }}"
  - name: install Phoenix (latest)
    ansible.builtin.shell: |
      {{ source }}
      mix archive.install hex phx_new --force
    args:
      executable: '{{ ansible_user_shell }}'
    register: result
    when: phoenix == 'latest'
    vars: 
      source: "{{ shenv.stdout_lines | map('regex_replace', '(^)', '. ') | join('\n') }}"
  - name: install Phoenix (not latest)
    ansible.builtin.shell: |
      {{ source }}
      mix archive.install hex phx_new {{ phoenix }} --force
    args:
      executable: '{{ ansible_user_shell }}'
    register: result
    when: phoenix != 'latest'
    vars: 
      source: "{{ shenv.stdout_lines | map('regex_replace', '(^)', '. ') | join('\n') }}"
  vars:
    - asdfsh: "{{ ansible_user_dir | quote }}/.asdf/asdf.sh"
    - profile: "{{ ansible_user_dir }}/.profile"
    - shprofile: "{{ ansible_user_dir }}/.{{ ansible_user_shell | basename | regex_replace('$', '_') | regex_replace('zsh_', 'z') }}profile"
    - shrc: "{{ ansible_user_dir }}/.{{ ansible_user_shell | basename }}rc"
    - shenv_cmd: "if [ -e {{ asdfsh }} ]; then echo '{{ asdfsh }}'; fi; if [ -e {{ shprofile }} ]; then echo '{{ shprofile }}'; fi; if [ -e {{ profile }} ]; then echo '{{ profile }}'; fi; if [ -e {{ shrc }} ]; then echo '{{ shrc }}'; fi"
```

## Nervesをインストールする

```yaml:tasks/0301_install_nerves.yml
---
- block:
  - name: sh env
    ansible.builtin.shell:
    args:
      cmd: "{{ shenv_cmd }}"
      chdir: '{{ ansible_user_dir }}/'
    register: shenv
  - name: install Nerves (latest)
    ansible.builtin.shell: |
      {{ source }}
      mix local.rebar --force
      mix local.hex --force
      mix archive.install hex nerves_bootstrap --force
    args:
      executable: '{{ ansible_user_shell }}'
    register: result
    when: nerves == 'latest'
    vars: 
      source: "{{ shenv.stdout_lines | map('regex_replace', '(^)', '. ') | join('\n') }}"
  - name: install Nerves (not latest)
    ansible.builtin.shell: |
      {{ source }}
      mix local.rebar --force
      mix local.hex --force
      mix archive.install hex nerves_bootstrap {{ nerves }} --force
    args:
      executable: '{{ ansible_user_shell }}'
    register: result
    when: nerves != 'latest'
    vars: 
      source: "{{ shenv.stdout_lines | map('regex_replace', '(^)', '. ') | join('\n') }}"
  vars:
    - asdfsh: "{{ ansible_user_dir | quote }}/.asdf/asdf.sh"
    - profile: "{{ ansible_user_dir }}/.profile"
    - shprofile: "{{ ansible_user_dir }}/.{{ ansible_user_shell | basename | regex_replace('$', '_') | regex_replace('zsh_', 'z') }}profile"
    - shrc: "{{ ansible_user_dir }}/.{{ ansible_user_shell | basename }}rc"
    - shenv_cmd: "if [ -e {{ asdfsh }} ]; then echo '{{ asdfsh }}'; fi; if [ -e {{ shprofile }} ]; then echo '{{ shprofile }}'; fi; if [ -e {{ profile }} ]; then echo '{{ profile }}'; fi; if [ -e {{ shrc }} ]; then echo '{{ shrc }}'; fi"
```

# Playbook

これらのタスクをもとにPlaybookを組み上げることができます。この節ではいくつかの例を示します。

## Asdfをインストールする

```yaml:playbook/0010_install_asdf.yml
- name: install asdf
  hosts: all
  tasks:
    - include_tasks: ../tasks/0010_install_asdf_linux.yml
      when: ansible_system == 'Linux' and (ansible_distribution == 'Ubuntu' or ansible_distribution == 'Debian')
    - include_tasks: ../tasks/0010_install_asdf_macos.yml
      when: ansible_system == 'Darwin'
```

## Erlangの前提ライブラリをインストールする

```yaml:playbook/0011_install_erlang_prerequisite.yml
- name: install prerequisites of erlang
  hosts: all
  tasks:
    - include_tasks: ../tasks/0011_install_erlang_prerequisite_linux.yml
      when: ansible_system == 'Linux' and (ansible_distribution == 'Ubuntu' or ansible_distribution == 'Debian')
    - include_tasks: ../tasks/0011_install_erlang_prerequisite_macos.yml
      when: ansible_system == 'Darwin'
```

## Nervesの前提ライブラリをインストールする

```yaml:playbook/0013_install_nerves_prerequisite.yml
- name: install prerequisites of nerves
  hosts: all
  tasks:
    - include_tasks: ../tasks/0013_install_nerves_prerequisite_linux.yml
      when: ansible_system == 'Linux' and (ansible_distribution == 'Ubuntu' or ansible_distribution == 'Debian')
    - include_tasks: ../tasks/0013_install_nerves_prerequisite_macos.yml
      when: ansible_system == 'Darwin'
```

## プラグインをインストールする

```yaml:playbook/0020_install_plugins.yml
- name: install erlang/elixir plugins for asdf
  hosts: all
  tasks:
    - include_tasks: ../tasks/0021_install_erlang_plugin.yml
    - include_tasks: ../tasks/0022_install_elixir_plugin.yml
```

## ErlangとElixirをインストールする

```yaml:playbook/0100_install_erlang_elixir.yml
- name: install erlang/elixir with asdf
  hosts: all
  tasks:
    - include_tasks: ../tasks/0101_install_erlang.yml
    - include_tasks: ../tasks/0102_install_elixir.yml
```

## Phoenixをインストールする

```yaml:playbook/0200_install_phoenix.yml
- name: install phoenix with asdf
  hosts: all
  tasks:
    - include_tasks: ../tasks/0201_install_phoenix.yml
```

## Nervesをインストールする

```yaml:playbook/0300_install_nerves.yml
- name: install nerves with asdf
  hosts: all
  tasks:
    - include_tasks: ../tasks/0301_install_nerves.yml
```

# 使用方法

playbookを次のように実行します。

```sh
ansible-playbook -f (ターゲット数) -i (inventoryファイル) (playbookファイル)
```

たとえば，ErlangとElixirを`target1, target2, ..., target9` にインストールするには次のようにします。

```sh
ansible-playbook -f 9 -i inventory/inventory.yml playbook/0100_install_erlang_elixir.yml
```

もしplaybookを実行するときに管理者権限になる必要がある場合には，次のようにします。

```sh
ansible-playbook -f (ターゲット数) -i (inventoryファイル) (playbookファイル) --ask-become-pass
```

たとえば，Asdfを`target1, target2, ..., target9` にインストールする場合で，ターゲットに1台以上のUbuntuが含まれている場合には，次のようにします。

```sh
ansible-playbook -f 9 -i inventory/inventory.yml playbook/0010_install_asdf.yml --ask-become-pass
```
