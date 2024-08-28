#!/bin/bash

# Проверка наличия установленных пакетов
check_package() {
    dpkg -s "$1" > /dev/null 2>&1
    return $?
}

# Определение дистрибутива
distro=""
if [ -e "/etc/os-release" ]; then
    source "/etc/os-release"
    distro="$ID"
elif [ -e "/etc/redhat-release" ]; then
    distro="centos"
fi

if [ "$distro" == "amzn" ]; then
    distro="amazon"
fi

# Установка git, htop, nano
if ! check_package "git" || ! check_package "htop" || ! check_package "nano"; then
    echo "Установка git, htop, nano..."
    case "$distro" in
        "ubuntu" | "debian" | "pop")
            sudo apt-get update
            sudo apt-get install -y git htop nano
            ;;
        "fedora" | "amazon" | "centos" | "rhel")
            if command -v dnf > /dev/null; then
                sudo dnf install -y git htop nano
            else
                sudo yum install -y git htop nano
            fi
            ;;
        *)
            echo "Не удалось определить дистрибутив."
            exit 1
            ;;
    esac
else
    echo "git, htop, nano уже установлены."
fi

# Установка Powerline fonts, если не установлены
if ! check_package "fonts-powerline"; then
    echo "Установка Powerline fonts..."
    case "$distro" in
        "ubuntu" | "debian" | "pop")
            sudo apt-get install -y fonts-powerline
            ;;
        "fedora" | "amazon" | "centos" | "rhel")
            if command -v dnf > /dev/null; then
                sudo dnf install -y powerline-fonts
            else
                sudo yum install -y epel-release
                sudo yum install -y powerline-fonts
            fi
            ;;
        *)
            echo "Не удалось определить дистрибутив."
            exit 1
            ;;
    esac

    # Добавление настроек Powerline в конфигурацию Bash
    cat <<EOL >> ~/.bashrc

# Powerline configuration
if [ -f /usr/share/powerline/bindings/bash/powerline.sh ]; then
  powerline-daemon -q
  POWERLINE_BASH_CONTINUATION=1
  POWERLINE_BASH_SELECT=1
  source /usr/share/powerline/bindings/bash/powerline.sh
fi
EOL
else
    echo "Powerline fonts уже установлены."
fi

# Установка Zsh, если не установлен
if ! check_package "zsh"; then
    echo "Установка Zsh..."
    case "$distro" in
        "ubuntu" | "debian" | "pop")
            sudo apt-get install -y zsh
            ;;
        "fedora" | "amazon" | "centos" | "rhel")
            if command -v dnf > /dev/null; then
                sudo dnf install -y zsh
            else
                sudo yum install -y zsh
            fi
            ;;
        *)
            echo "Не удалось определить дистрибутив."
            exit 1
            ;;
    esac
else
    echo "Zsh уже установлен."
fi

# Установка Oh My Zsh, если не установлен
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Установка Oh My Zsh..."
    RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    echo "Oh My Zsh уже установлен."
fi

# Установка темы agnoster для Zsh
sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="agnoster"/' ~/.zshrc

# Установка Zsh как оболочки по умолчанию
sudo chsh -s $(which zsh)

# Вход в Zsh
# exec zsh
