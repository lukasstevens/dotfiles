{ stdenv, base16-builder, colors }:

stdenv.mkDerivation rec {
  pname = "my-base16-theme";
  version = "stable";

  nativeBuildInputs = [
    base16-builder
  ];

  src = ./.;

  buildPhase = ''
    cat <<EOF > my-base16.yml
    scheme: "my-base16"
    author: "Lukas Stevens (https://github.com/lukasstevens)"
    # Default Background
    base00: "${colors.base00}"
    # Lighter Background
    base01: "${colors.base01}"
    # Selection Background
    base02: "${colors.base02}"
    # Comments, Invisibles, Line Highlighting
    base03: "${colors.base03}"
    # Dark Foreground (Used for status bars)
    base04: "${colors.base04}"
    # Default Foreground, Caret, Delimiters, Operators
    base05: "${colors.base05}"
    # Light Foreground
    base06: "${colors.base06}"
    # Light Foreground
    base07: "${colors.base07}"
    # Variables, XML Tags, Markup Link Text, Markup Lists, Diff Deleted
    base08: "${colors.base08}"
    # Integers, Boolean, Constants, XML Attributes, Markup Link URL
    base09: "${colors.base09}"
    # Classes, Markup Bold, Search Text Background
    base0A: "${colors.base0A}"
    # Strings, Inherited Class, Markup Code, Diff Inserted
    base0B: "${colors.base0B}"
    # Support, Regex, Escape Characters, Markup Quotes
    base0C: "${colors.base0C}"
    # Functions, Methods, Attribute IDs, Headings
    base0D: "${colors.base0D}"
    # Keywords, Storage, Selector, Markup, Italic, Diff Changed
    base0E: "${colors.base0E}"
    # Deprecated, Opening/Closing Embedded Language Tags
    base0F: "${colors.base0F}"
    EOF

    HOME=$(mktemp -d)
    base16-builder -s my-base16.yml -b dark -t shell > my-base16.sh
    base16-builder -s my-base16.yml -b dark -t vim > my-base16.vim
    '';

  installPhase = ''
    mkdir -p $out/share
    cp my-base16.sh $out/share
    cp my-base16.vim $out/share
    '';
}
