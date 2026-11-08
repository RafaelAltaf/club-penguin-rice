source /usr/share/cachyos-fish-config/cachyos-config.fish

# Club Penguin Rice - Kitty Greeting
function fish_greeting
    if set -q KITTY_WINDOW_ID
        fastfetch \
            --logo-type kitty \
            --logo "$HOME/Documentos/ProjetosPessoais/club-penguin-rice/assets/loading-gifs/*.gif" \
            --logo-width 24 \
            --logo-animation-frame 0
    end
end
