#!/usr/bin/env fish

# Club Penguin Rice - Fastfetch Installer

set script_path (realpath (status --current-filename))
set project_root (dirname (dirname "$script_path"))

set gif_dir "$project_root/assets/loading-gifs"
set data_dir "$HOME/.local/share/club-penguin-rice"
set fish_config "$HOME/.config/fish/config.fish"

set start_marker "# >>> Club Penguin Rice Fastfetch >>>"
set end_marker "# <<< Club Penguin Rice Fastfetch <<<"

set action install
if test (count $argv) -gt 0
    set action $argv[1]
end

function install_fastfetch
    if not type -q fastfetch
        echo "ERRO: Fastfetch não está instalado."
        return 1
    end

    if not test -d "$gif_dir"
        echo "ERRO: pasta de GIFs não encontrada."
        return 1
    end

    set gifs (find "$gif_dir" -maxdepth 1 -type f -iname '*.gif')

    if test (count $gifs) -eq 0
        echo "ERRO: nenhum GIF encontrado."
        return 1
    end

    mkdir -p "$HOME/.local/share"
    mkdir -p "$HOME/.config/fish"

    # Create or validate the repository symlink.
    if test -L "$data_dir"
        set target (realpath "$data_dir")

        if test "$target" != "$project_root"
            echo "ERRO: o link existente aponta para outro destino."
            return 1
        end
    else if test -e "$data_dir"
        echo "ERRO: já existe um arquivo ou diretório em $data_dir"
        return 1
    else
        ln -s "$project_root" "$data_dir"
        or return 1
    end

    touch "$fish_config"

    # Avoid installing the integration twice.
    if grep -qF "$start_marker" "$fish_config"
        echo "A integração já está instalada."
        return 0
    end

    # Preserve the previous greeting if one exists.
    printf '\n%s\n' \
        "$start_marker" \
        'if not functions -q __cpr_original_fish_greeting' \
        '    if functions -q fish_greeting' \
        '        functions --copy fish_greeting __cpr_original_fish_greeting' \
        '    end' \
        'end' \
        '' \
        'function fish_greeting' \
        '    if set -q KITTY_WINDOW_ID' \
        '        fastfetch --logo-type kitty --logo "$HOME/.local/share/club-penguin-rice/assets/loading-gifs/*.gif" --logo-width 24 --logo-animation-frame 0' \
        '    else if functions -q __cpr_original_fish_greeting' \
        '        __cpr_original_fish_greeting' \
        '    end' \
        'end' \
        "$end_marker" \
        >> "$fish_config"

    or return 1

    echo
    echo "✓ Link do projeto configurado"
    echo "✓ Integração do Fastfetch instalada"
    echo "✓ Inicialização exclusiva do Kitty"
    echo
    echo "Abra uma nova janela do Kitty para testar."
end

function uninstall_fastfetch
    if test -f "$fish_config"
        sed -i \
            "/^$start_marker\$/,/^$end_marker\$/d" \
            "$fish_config"
    end

    # Remove only our own repository symlink.
    if test -L "$data_dir"
        set target (realpath "$data_dir")

        if test "$target" = "$project_root"
            rm "$data_dir"
            echo "✓ Link do projeto removido"
        end
    end

    echo
    echo "✓ Integração do Fastfetch removida."
    echo "Suas outras configurações foram preservadas."
end

switch "$action"
    case install
        install_fastfetch
    case uninstall
        uninstall_fastfetch
    case '*'
        echo "Uso: ./scripts/install-fastfetch.fish [install|uninstall]"
        exit 1
end
