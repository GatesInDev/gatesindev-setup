#!/bin/bash
# Script de instalação local do ambiente de GatesInDev
# Autor: GatesInDev

set -e
LOGFILE="$HOME/gatesindev_install.log"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log() {
  echo -e "$1" | tee -a "$LOGFILE"
}

log "\n[INFO] Iniciando instalação do ambiente GatesInDev..."

# Atualização e instalação
log "[INFO] Atualizando sistema e instalando pacotes..."
sudo pacman -Syu --noconfirm
sudo pacman -S --noconfirm reflector git sudo vim nano networkmanager unzip zip unrar tmux mesa alsa-utils neofetch alacritty xorg xinit openbox lxappearance conky rofi tint2 nitrogen firefox

log "[INFO] Atualizando mirrors com Reflector..."
if ! sudo reflector --latest 200 --country Brazil --protocol https --sort rate --save /etc/pacman.d/mirrorlist; then
  log "[ERRO] Falha ao atualizar mirrors com Reflector."
  exit 1
fi

# Criando .xinitrc
log "[INFO] Configurando ~/.xinitrc..."
echo "exec openbox-session" > ~/.xinitrc

# Ativando NetworkManager
log "[INFO] Ativando NetworkManager..."
sudo systemctl enable NetworkManager
sudo systemctl start NetworkManager

# Copiando configurações do diretório local
log "[INFO] Copiando arquivos de configuração a partir do diretório local..."

mkdir -p ~/.config

for dir in openbox conky tint2; do
  if [ -d "$SCRIPT_DIR/$dir" ]; then
    cp -r "$SCRIPT_DIR/$dir" ~/.config/
    log "[OK] Copiado: $dir"
  else
    log "[WARN] Diretório não encontrado: $dir"
  fi
done

# Garantindo que o autostart exista
AUTOSTART="$HOME/.config/openbox/autostart"
if [ ! -f "$AUTOSTART" ]; then
  log "[INFO] Criando autostart padrão..."
  cat <<EOF > "$AUTOSTART"
#!/bin/bash
nitrogen --set-zoom-fill ~/gatesindev-setup/wallpapers/active.png --save &
tint2 &
conky &
EOF
  chmod +x "$AUTOSTART"
fi

log "\nInstalação concluída! Você pode rodar 'startx' para iniciar o ambiente Openbox."
