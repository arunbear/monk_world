use v5.40;
use Test::Most tests => 16;
use MonkWorld::TextProcessor 'apply_custom_markup';

subtest 'wikipedia links are converted' => sub {
    is(
        apply_custom_markup('[wp://Web_template_system]'),
        '<a href="https://en.wikipedia.org/wiki/Web_template_system">Web_template_system</a>'
    );
    
    is(
        apply_custom_markup('[wp://Web_template_system|Web Templates]'),
        '<a href="https://en.wikipedia.org/wiki/Web_template_system">Web Templates</a>'
    );
};

subtest 'wikipedia links with spaces are converted' => sub {
    is(
        apply_custom_markup('[wp://Web template system]'),
        '<a href="https://en.wikipedia.org/wiki/Web_template_system">Web template system</a>'
    );
};

subtest 'cpan module links are converted' => sub {
    is(
        apply_custom_markup('[mod://HTML::Template]'),
        '<a href="https://metacpan.org/pod/HTML::Template">HTML::Template</a>'
    );
    
    is(
        apply_custom_markup('[mod://HTML::Template|HTML Template Module]'),
        '<a href="https://metacpan.org/pod/HTML::Template">HTML Template Module</a>'
    );
};

subtest 'perldoc links are converted' => sub {
    is(
        apply_custom_markup('[doc://perlfunc]'),
        '<a href="https://perldoc.perl.org/perlfunc">perlfunc</a>'
    );
    
    is(
        apply_custom_markup('[doc://perlop|Perl Operators]'),
        '<a href="https://perldoc.perl.org/perlop">Perl Operators</a>'
    );
    
    is(
        apply_custom_markup('See [doc://perlre|Regular Expressions] for details'),
        'See <a href="https://perldoc.perl.org/perlre">Regular Expressions</a> for details'
    );
};

subtest 'mixed link types are converted' => sub {
    is(
        apply_custom_markup('[mod://HTML::Template] is a popular [wp://Web template system]'),
        '<a href="https://metacpan.org/pod/HTML::Template">HTML::Template</a> is a popular <a href="https://en.wikipedia.org/wiki/Web_template_system">Web template system</a>'
    );
};

subtest 'plain text is unchanged' => sub {
    is(
        apply_custom_markup('This is plain text'),
        'This is plain text'
    );
};

subtest 'empty strings are handled' => sub {
    is(
        apply_custom_markup(''),
        ''
    );
};

subtest 'undefined input is handled' => sub {
    is(
        apply_custom_markup(undef),
        ''
    );
};

subtest 'multiple wikipedia links are converted' => sub {
    is(
        apply_custom_markup('See [wp://Perl] and [wp://Python] for examples'),
        'See <a href="https://en.wikipedia.org/wiki/Perl">Perl</a> and <a href="https://en.wikipedia.org/wiki/Python">Python</a> for examples'
    );
};

subtest 'multiple cpan links are converted' => sub {
    is(
        apply_custom_markup('Use [mod://Moose] or [mod://Moo] for OOP'),
        'Use <a href="https://metacpan.org/pod/Moose">Moose</a> or <a href="https://metacpan.org/pod/Moo">Moo</a> for OOP'
    );
};

subtest 'complex module names are converted' => sub {
    is(
        apply_custom_markup('[mod://DBI::mysql] and [mod://MooseX-MethodAttributes]'),
        '<a href="https://metacpan.org/pod/DBI::mysql">DBI::mysql</a> and <a href="https://metacpan.org/pod/MooseX-MethodAttributes">MooseX-MethodAttributes</a>'
    );
};

subtest 'wikipedia links with special characters are converted' => sub {
    is(
        apply_custom_markup('[wp://C++], [wp://C#], and [wp://.NET Framework]'),
        '<a href="https://en.wikipedia.org/wiki/C++">C++</a>, <a href="https://en.wikipedia.org/wiki/C#">C#</a>, and <a href="https://en.wikipedia.org/wiki/.NET_Framework">.NET Framework</a>'
    );
};

subtest 'unmatched brackets are ignored' => sub {
    is(
        apply_custom_markup('This has [wp://unclosed and [normal text'),
        'This has [wp://unclosed and [normal text'
    );
};

subtest 'perlmonks id links are converted' => sub {
    is(
        apply_custom_markup('[id://1153804|Wikisyntax for the Monastery]'),
        '<a href="https://perlmonks.org/?node_id=1153804">Wikisyntax for the Monastery</a>'
    );
    
    is(
        apply_custom_markup('[id://12345]'),
        '<a href="https://perlmonks.org/?node_id=12345">12345</a>'
    );
    
    is(
        apply_custom_markup('[id://999999|This node]'),
        '<a href="https://perlmonks.org/?node_id=999999">This node</a>'
    );
};

subtest 'generic http links are converted' => sub {
    is(
        apply_custom_markup('[https://www.example.com|Example Site]'),
        '<a href="https://www.example.com">Example Site</a>'
    );
    
    is(
        apply_custom_markup('[http://perl.org]'),
        '<a href="http://perl.org">http://perl.org</a>'
    );
    
    is(
        apply_custom_markup('[https://github.com/user/repo|my repository]'),
        '<a href="https://github.com/user/repo">my repository</a>'
    );
};

subtest 'perlmonks node links are converted' => sub {
    is(
        apply_custom_markup('[foo]'),
        '<a href="https://www.perlmonks.org/?node=foo">foo</a>'
    );
    
    is(
        apply_custom_markup('[Wikisyntax]'),
        '<a href="https://www.perlmonks.org/?node=Wikisyntax">Wikisyntax</a>'
    );
    
    is(
        apply_custom_markup('See [SOPW] for more information'),
        'See <a href="https://www.perlmonks.org/?node=SOPW">SOPW</a> for more information'
    );
    
    # Ensure [foo] pattern doesn't interfere with other patterns
    is(
        apply_custom_markup('[wp://Test] and [mod://Moose] and [foo]'),
        '<a href="https://en.wikipedia.org/wiki/Test">Test</a> and <a href="https://metacpan.org/pod/Moose">Moose</a> and <a href="https://www.perlmonks.org/?node=foo">foo</a>'
    );
};

done_testing();
