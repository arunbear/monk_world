package MonkWorld::Controller::Search;
use v5.40;
use Mojo::Base 'Mojolicious::Controller', -signatures;
use MonkWorld::API::Request;
use Data::Dump qw(dump);
use Role::Tiny::With;

with 'MonkWorld::Role::ApiClient';

sub index ($self) {
    my $validation = $self->validation;
    $validation->optional('q')->size(1, 100);
    $validation->optional('os')->num(0, undef); # only some sections
    $validation->optional('xs')->num(0, undef); # exclude sections

    if ($validation->has_error) {
        my %errors = map { $_ => [$validation->error($_)] } $validation->failed->@*;
        $self->log->warn("Invalid search parameters ignored: " . dump(\%errors));
    }

    my $sitemap = $self->get_sitemap;
    my $req = MonkWorld::API::Request
        ->new(
            link_meta => $sitemap->{_links}{search},
            server    => $self->api_url,
            with_auth_token => false,
        );

    # Add form parameters if they exist
    my $q = $validation->param('q');
    my $include_sections = $validation->every_param('os');
    my $exclude_sections = $validation->every_param('xs');

    $req->update_form_entries(
        ($q ? (q => $q) : ()),
        (@$include_sections ? (os => $include_sections) : ()),
        (@$exclude_sections ? (xs => $exclude_sections) : ()),
    );

    my $tx = $self->app->ua->build_tx($req->tx_args);
    my $res = $self->app->ua->start($tx)->result;
    my $results = $res->json;
    $self->log->debug("Response code: " . $res->code);
    $self->log->debug("Response message: " . $res->message);
    $self->log->debug("Search results: " . dump($results));

    $self->render(results => $results);
}

__END__
