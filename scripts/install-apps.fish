#!/usr/bin/env fish

# Club Penguin Rice - Application Installer

set script_dir (dirname (realpath (status --current-filename)))
set project_root (dirname $script_dir)
set package_dir "$project_root/packages"

set categories desktop development gaming multimedia productivity

set requested_category all
if test (count $argv) -gt 0
    set requested_category $argv[1]
end

if not type -q pacman
    echo "ERRO: pacman não encontrado."
    exit 1
end

if test "$requested_category" = all
    set selected_categories $categories
else if contains -- $requested_category $categories
    set selected_categories $requested_category
else
    echo "Categoria inválida: $requested_category"
    echo
    echo "Uso: ./scripts/install-apps.fish [all|desktop|development|gaming|multimedia|productivity]"
    exit 1
end

set to_install
set unavailable

echo "Club Penguin Rice - Instalador de aplicativos"
echo

for category in $selected_categories
    set package_file "$package_dir/$category.txt"

    if not test -f "$package_file"
        echo "ERRO: arquivo não encontrado: $package_file"
        exit 1
    end

    echo "== $category =="

    while read -l package
        test -z "$package"; and continue

        if pacman -Q "$package" >/dev/null 2>&1
            echo "  ✓ Já instalado: $package"
        else if pacman -Si "$package" >/dev/null 2>&1
            echo "  + Será instalado: $package"
            set -a to_install $package
        else
            echo "  ! Pacote indisponível nos repositórios: $package"
            set -a unavailable $package
        end
    end < "$package_file"

    echo
end

if test (count $unavailable) -gt 0
    echo "ERRO: existem pacotes indisponíveis."
    echo "Verifique os repositórios e a disponibilidade desses pacotes."
    exit 1
end

if test (count $to_install) -eq 0
    echo "Todos os aplicativos selecionados já estão instalados!"
    exit 0
end

echo "Pacotes que serão instalados:"
printf '  %s\n' $to_install
echo

read -P "Deseja continuar? [s/N] " confirmation

if not string match -qi 's*' -- "$confirmation"
    echo "Instalação cancelada."
    exit 0
end

sudo pacman -S --needed $to_install

if test $status -eq 0
    echo
    echo "Instalação concluída!"
else
    echo
    echo "A instalação apresentou um erro."
    exit 1
end
