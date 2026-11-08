#!/usr/bin/env fish

# Club Penguin Rice - Sticker Icon Generator

# Localiza a raiz do projeto a partir deste script.
set script_dir (dirname (realpath (status filename)))
set project_root (dirname $script_dir)
set output "$project_root/assets/icons/applications/sticker-tests"

mkdir -p "$output"


function make_sticker
    set source $argv[1]
    set name $argv[2]

    set base "/tmp/cpr-$name-base.png"
    set mask "/tmp/cpr-$name-mask.png"
    set outline "/tmp/cpr-$name-outline.png"
    set destination "$output/$name.png"

    if not test -f "$source"
        echo "ERRO: arquivo não encontrado: $source"
        return 1
    end

    # Renderiza o ícone em RGBA, preservando as cores.
    magick -background none "$source" \
        -trim +repage \
        -resize 420x420 \
        -gravity center \
        -extent 512x512 \
        "PNG32:$base" || return 1

    # Extrai e expande somente a transparência.
    magick "$base" \
        -alpha extract \
        -morphology Dilate Disk:24 \
        "$mask" || return 1

    # Cria o contorno branco usando a máscara como alfa.
    magick -size 512x512 xc:white \
        -alpha off \
        "$mask" \
        -compose CopyOpacity \
        -composite \
        "$outline" || return 1

    # Coloca o ícone colorido sobre o contorno.
    magick "$base" "$outline" \
        -compose DstOver \
        -composite \
        "PNG32:$destination" || return 1

    echo "✓ Adesivo criado: $destination"
end

set failed 0

# make_sticker "/usr/share/icons/Zafiro-icons/Dark/apps/scalable/code.svg" vscode
# or set failed 1

# make_sticker "/usr/share/icons/Zafiro-icons/Dark/apps/scalable/Alacritty.svg" alacritty
# or set failed 1

#make_sticker "/usr/share/icons/Papirus/64x64/apps/zed.svg" zed
#or set failed 1

#make_sticker "assets/icons/applications/steam.webp" steam
#or set failed 1

#make_sticker "assets/icons/applications/vlc.webp" vlc
#or set failed 1

#make_sticker "assets/icons/applications/brave.webp" brave
#or set failed 1

echo

if test $failed -eq 0
    echo "Adesivos de teste criados com sucesso!"
else
    echo "Alguns adesivos não puderam ser criados."
    exit 1
end
