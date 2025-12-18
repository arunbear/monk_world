package MonkWorld::Controller::Threads;
use v5.40;
use Mojo::Base 'Mojolicious::Controller', -signatures;
use MonkWorld::API::Request;
use Data::Dumper;
use Role::Tiny::With;

with 'MonkWorld::Role::ApiClient';

sub index ($self) {
    my $sitemap = $self->get_sitemap;
    my $req = MonkWorld::API::Request
        ->new(
            link_meta => $sitemap->{_links}{get_threads},
            server    => $self->api_url,

            with_auth_token => false,
        );

    my $tx = $self->app->ua->build_tx($req->tx_args);
    my $res = $self->app->ua->start($tx)->result;
    my $threads = $res->json;
    $self->log->debug("Threads: " . Dumper($threads));

    $self->render(threaded => $threads, counter => make_counter());
}

sub make_counter () {
    my $count = 1;
    return sub { $count++ };
}

__END__
