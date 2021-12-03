{ stdenv, base16-builder, fetchFromGitHub }:

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
    base00: "262528"
    # Lighter Background
    base01: "272935"
    # Selection Background
    base02: "3a4055"
    # Comments, Invisibles, Line Highlighting
    base03: "5a647e"
    # Dark Foreground (Used for status bars)
    base04: "d4cfc9"
    # Default Foreground, Caret, Delimiters, Operators
    base05: "e6e1dc"
    # Light Foreground
    base06: "f4f1ed"
    # Light Foreground
    base07: "f9f7f3"
    # Variables, XML Tags, Markup Link Text, Markup Lists, Diff Deleted
    base08: "de3e2f"
    # Integers, Boolean, Constants, XML Attributes, Markup Link URL
    base09: "59abe3"
    # Classes, Markup Bold, Search Text Background
    base0A: "f89406"
    # Strings, Inherited Class, Markup Code, Diff Inserted
    base0B: "6fd952"
    # Support, Regex, Escape Characters, Markup Quotes
    base0C: "1BBC9B"
    # Functions, Methods, Attribute IDs, Headings
    base0D: "4183d7"
    # Keywords, Storage, Selector, Markup, Italic, Diff Changed
    base0E: "b24edd"
    # Deprecated, Opening/Closing Embedded Language Tags
    base0F: "bc9458"
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
