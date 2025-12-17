package MonkWorld::Controller::Threads;
use v5.40;
use Mojo::Base 'Mojolicious::Controller', -signatures;
use MonkWorld::API::Request;
use Data::Dumper;

sub index ($self) {
    my $sitemap = get_sitemap($self);
    my $req = MonkWorld::API::Request
        ->new(
            link_meta => $sitemap->{_links}{get_threads},
            server    => $self->config->{api}{url},

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

sub get_sitemap ($self) {
    state $sitemap = do {
        my $res = $self->app->ua->get($self->config->{api}{url})->result;
        if (!$res->is_success) {
            my $message = "Failed to fetch sitemap: " . $res->message;
            $self->log->error($message);
            die $message;
        }
        $res->json;
    };
    return $sitemap;
}

__END__
