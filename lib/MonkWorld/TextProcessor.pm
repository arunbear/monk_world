package MonkWorld::TextProcessor;
use v5.40;
use Exporter 'import';
our @EXPORT_OK = qw(apply_custom_markup);

sub apply_custom_markup ($text) {
    return '' unless defined $text;

    # Process content outside code blocks only
    $text = _process_text_with_code_blocks($text);

    return $text;
}

sub _process_text_with_code_blocks ($text) {
    my $result = '';

    # Process text while preserving code blocks (both <code> and <c> tags)
    while ($text =~ m{(.*?)(<(code|c)>(.*?)</\3>)(.*)}is) {
        my ($before, $code_block, $tag_type, $content, $after) = ($1, $2, $3, $4, $5);

        # Process text before code block
        $result .= _process_markup($before);

        # Convert code block to <pre> tag with preserved content
        $result .= "<pre>$content</pre>";

        # Continue with remaining text
        $text = $after;
    }

    # Process any remaining text (after the last code block)
    $result .= _process_markup($text);

    return $result;
}

sub _process_markup ($text) {
    $text = _process_wp_links($text);

    # Convert [mod://Module_Name|text] to CPAN links
    $text =~ s{\[(?:meta)?mod://([^\|\]]+)\|([^\]]+)\]}{<a href="https://metacpan.org/pod/$1">$2</a>}gi;
    $text =~ s{\[(?:meta)?mod://([^\]]+)\]}{<a href="https://metacpan.org/pod/$1">$1</a>}gi;

    # Convert [doc://foo|text] to perldoc links
    $text =~ s{\[doc://([^\|\]]+)\|([^\]]+)\]}{<a href="https://perldoc.perl.org/$1">$2</a>}g;
    $text =~ s{\[doc://([^\]]+)\]}{<a href="https://perldoc.perl.org/$1">$1</a>}g;

    # Convert [id://number|text] to PerlMonks links
    $text =~ s{\[id://(\d+)\|([^\]]+)\]}{<a href="https://perlmonks.org/?node_id=$1">$2</a>}g;
    $text =~ s{\[id://(\d+)\]}{<a href="https://perlmonks.org/?node_id=$1">$1</a>}g;

    # Convert [http://url|text] to generic links
    $text =~ s{\[(https?://[^\|\]]+)\|([^\]]+)\]}{<a href="$1">$2</a>}g;
    $text =~ s{\[(https?://[^\]]+)\]}{<a href="$1">$1</a>}g;

    # Convert [foo] to PerlMonks node links (must be last to avoid conflicts)
    $text =~ s{\[([^\]:/]+)\]}{<a href="https://www.perlmonks.org/?node=$1">$1</a>}g;

    return $text;
}

sub _process_wp_links ($text) {
    # Convert [wp://Page_Name|text] to Wikipedia links
    $text =~ s{
        \[wp://           # opening bracket and wp:// protocol
        ([^ \| \] ]+)     # capture page name (anything but | or ])
        \|                # separator
        ([^\]]+)          # capture alternate text (anything but ])
        \]                # closing bracket
    }{<a href="https://en.wikipedia.org/wiki/$1">$2</a>}gix;
    $text =~ s{\[wp://([^\]]+)\]}{
        my $page_name = $1;
        my $url_name = $page_name;
        $url_name =~ s/ /_/g;
        "<a href=\"https://en.wikipedia.org/wiki/$url_name\">$page_name</a>";
    }egi;

    return $text;
}
