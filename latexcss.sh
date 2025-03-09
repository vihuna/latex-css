#!/bin/bash

export_command=$1
syntax_errors="true"

function print_help() {
	cat <<EOT
latexcss.sh

Usage:
	./latexcss.sh <html2latex|html2pdf|latex2html|help> [input_file] [output_file]

EOT
}

if [[ -n $1 ]] && [[ -n $2 ]] && [[ -n $3 ]]; then
	syntax_errors="false"
fi

if [[ -n $1 ]] && [[ -z $2 ]] && [[ -z $3 ]]; then
	syntax_errors="false"
fi

if [[ syntax_errors == "true" ]]; then
	echo "latexcss: command syntax error. Type './latexcss help' get info."
else
	case $export_command in
		html2pdf)
			if [[ -n $2 ]]; then
				input_file=$2
				output_file=$3
				output_file_tex="${output_file%%.*}.tex"
			else
				input_file="index.html"
				output_file="index.pdf"
				output_file_tex="index.tex"
			fi
			# Copy files to dist folder
			mkdir -p dist/html2latex
			cp -u ./$input_file ./dist/html2latex/$input_file
			cp -u ./pandoc/html_lcss2latex.lua ./dist/html2latex/html_lcss2latex.lua
			cp -u ./pandoc/html_lcss_reader.lua ./dist/html2latex/html_lcss_reader.lua
			cp -u ./pandoc/custom_template.latex ./dist/html2latex/custom_template.latex
			cp -u ./pandoc/html_lcss2latex.yaml ./dist/html2latex/html_lcss2latex.yaml
			# Run Pandoc (`dist/html2latex` folder)
			cd ./dist/html2latex
			pandoc --defaults=html_lcss2latex.yaml -M chars="⊕/*" -M chars="📝/#" -M chars="↩/^" -o $output_file_tex $input_file
			# Run latexmk
			latexmk -pdf $output_file_tex
			;;
		latex2html)
			# Copy files to dist folder
			mkdir -p dist/latex2html
			mkdir -p dist/latex2html/prism
			mkdir -p dist/latex2html/fonts
			cp -u ./pandoc/index.tex dist/latex2html/index.tex
			cp -u ./pandoc/custom_template.html dist/latex2html/custom_template.html
			cp -u ./pandoc/latex2html_lcss.yaml dist/latex2html/latex2html_lcss.yaml
			cp -u ./pandoc/latex2html_lcss.lua dist/latex2html/latex2html_lcss.lua
			cp -u ./prism/prism.css dist/latex2html/prism/prism.css
			cp -u ./prism/prism.js dist/latex2html/prism/prism.js
			cp -u ./style.css dist/latex2html/style.css
			cp -u ./fonts/* dist/latex2html/fonts/
			# Run Pandoc (`dist/latex2html` folder)
			cd ./dist/latex2html
			pandoc --defaults=latex2html_lcss.yaml -o index.html index.tex
			;;
		help)
			print_help
			;;
		*)
			echo "latexcss: Incorrect export command. Type './latexcss help' get info'"
			;;
	esac
fi
