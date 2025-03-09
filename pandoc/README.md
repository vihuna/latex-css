# Export from/to LaTeX with Pandoc

Some basic files are provided here for a easy conversion from/to LaTeX using
[Pandoc](https://pandoc.org).

- `html_lcss_reader.lua`: not really a custom Pandoc reader, used to catch some missing HTML
  tags and some LaTeX.css particular constructions (sidenotes, footnotes ...).
- `html_lcss2latex.lua`: the Pandoc Lua file filter with all the filters for HTML+lcss to
LaTeX conversion.
- `custom_template.latex`: the default Pandoc LaTeX template, with some modifications for
  language localization and other LaTeX package configurations.
- `html_lcss2latex.yaml`: Pandoc "defaults" file where a package of default options are
specified for LaTeX conversion.
- `custom_template.html`: the default HTML template, with some modifications for specific
LaTeX.css document styles.
- `latex2html_lcss.lua`: the Pandoc Lua file filter with all the filters for LaTeX to
 HTML+lcss conversion.
- `latex2html_lcss.yaml`: Pandoc "defaults" file where a package of default options are
specified for HTML conversion.


## Required Software

- Pandoc
- Latexmk
- LaTeX distro
- LaTeX packages: `amsfonts`, `amsmath`, `lm`, `unicode-math`, `iftex`, `listings` (if the `--listings` option is used), `fancyvrb`, `longtable`, `booktabs`, `multirow` (if the document contains a table with cells that cross multiple rows), `graphicx` (if the document contains images), `bookmark`, `xcolor`, `soul`, `geometry` (if the geometry variable is set), `setspace` (if `linestretch` variable is set), and `babel`.


## Basic HTML+LaTeX.css to LaTeX conversion

```bash
pandoc --defaults=html_lcss2latex.yaml -o [output_file.tex] [input_file.html]
latexmk -pdf [output_file.tex]
```


## Basic LaTeX files to HTML+LaTeX.css conversion

```bash
pandoc --defaults=latex2html_lcss.yaml -o [output_file.html] [input_file.tex]
```



