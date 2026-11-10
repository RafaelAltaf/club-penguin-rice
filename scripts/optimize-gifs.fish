#!/usr/bin/env fish

# Club Penguin Rice - GIF Optimizer

set script_path (realpath (status --current-filename))
set project_root (dirname (dirname "$script_path"))

set source_dir "$project_root/assets/loading-gifs"
set output_dir "$source_dir/optimized"

if not type -q ffmpeg
    echo "ERRO: FFmpeg não está instalado."
    exit 1
end

if not test -d "$source_dir"
    echo "ERRO: pasta de GIFs não encontrada."
    exit 1
end

set gifs (find "$source_dir" -maxdepth 1 -type f -iname '*.gif' | sort)

if test (count $gifs) -eq 0
    echo "ERRO: nenhum GIF encontrado."
    exit 1
end

mkdir -p "$output_dir"

echo "Club Penguin Rice - Otimizador de GIFs"
echo "Resolução máxima: 240x240"
echo "Taxa de quadros: 12 FPS"
echo "Paleta: 128 cores"
echo

for gif in $gifs
    set filename (basename "$gif")
    set output "$output_dir/$filename"

    echo "Processando: $filename"

    ffmpeg \
        -hide_banner \
        -loglevel error \
        -y \
        -i "$gif" \
        -filter_complex "[0:v]fps=12,scale=240:240:force_original_aspect_ratio=decrease:flags=lanczos,split[a][b];[a]palettegen=max_colors=128:stats_mode=diff[p];[b][p]paletteuse=dither=bayer:bayer_scale=3:diff_mode=rectangle" \
        -loop 0 \
        "$output"

    or begin
        echo "ERRO ao processar: $filename"
        exit 1
    end

    echo "✓ $filename"
end

echo
echo "✓ Otimização concluída!"
echo "Arquivos salvos em: $output_dir"
