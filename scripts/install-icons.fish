#!/usr/bin/env fish

# Club Penguin Rice
# Gerenciamento dos ícones personalizados do dock.

set -l action install
if set -q argv[1]
    set action $argv[1]
end

if test "$action" != install -a "$action" != uninstall
    echo "Uso: ./scripts/install-icons.fish [install|uninstall]"
    exit 1
end

set -l script_dir (dirname (status --current-filename))
set -l repo_root (realpath "$script_dir/..")
set -l applications_dir "$HOME/.local/share/applications"

# Aplicativo:arquivo de ícone
set -l apps \
    brave-browser:brave.png \
    spotify-launcher:spotify.webp \
    thunar:file_manager.png \
    vlc:vlc.png \
    discord:discord.webp \
    io.dbeaver.DBeaver:dbeaver.webp \
    libreoffice-startcenter:libreoffice.webp \
    steam:steam.png \
    docker:docker.webp \
    org.gnome.Calculator:calculator.webp \
    org.gnome.TextEditor:text_editor.webp \
    Alacritty:alacritty.png \
    dev.zed.Zed:zed.png \
    code-oss:vscode.png


mkdir -p "$applications_dir"

for entry in $apps
    set -l parts (string split ':' -- $entry)
    set -l app $parts[1]
    set -l icon_file $parts[2]

    set -l source "/usr/share/applications/$app.desktop"
    set -l destination "$applications_dir/$app.desktop"
    set -l icon "$repo_root/assets/icons/applications/$icon_file"

    if test "$action" = install
        if not test -f "$source"
            echo "ERRO: aplicativo não encontrado: $source"
            continue
        end

        if not test -f "$icon"
            echo "ERRO: ícone não encontrado: $icon"
            continue
        end

        cp "$source" "$destination"
        sed -i "s|^Icon=.*|Icon=$icon|" "$destination"
        sed -i '1i# Managed by Club Penguin Rice' "$destination"

        echo "✓ $app"
    else
        if not test -f "$destination"
            echo "- Sem personalização: $app"
            continue
        end

        if grep -q '^# Managed by Club Penguin Rice$' "$destination"
            rm "$destination"
            echo "✓ Restaurado: $app"
        else
            echo "- Ignorado (arquivo não gerenciado): $app"
        end
    end
end

if command -q noctalia
    noctalia msg dock-reload
end

echo
if test "$action" = install
    echo "Ícones do Club Penguin Rice instalados!"
else
    echo "Personalizações gerenciadas removidas!"
end
