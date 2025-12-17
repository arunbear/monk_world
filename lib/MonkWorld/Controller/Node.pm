package MonkWorld::Controller::Node;
use v5.40;
use Mojo::Base 'Mojolicious::Controller', -signatures;
use MonkWorld::API::Request;
use Data::Dumper;

sub show ($self) {
    my $node_id = $self->stash('id');

    my $sitemap = get_sitemap($self);
    my $req = MonkWorld::API::Request
        ->new(
            link_meta => $sitemap->{_links}{get_thread},
            server    => $self->config->{api}{url},
            with_auth_token => false,
        )
        ->add_uri_segment($node_id);

    my $tx = $self->app->ua->build_tx($req->tx_args);
    my $res = $self->app->ua->start($tx)->result;

    if (!$res->is_success) {
        $self->log->error("Failed to fetch node $node_id: " . $res->message);
        return $self->render(text => 'Node not found', status => 404);
    }

    my $node_data = $res->json;
    my $node = $node_data->{$node_id};
    $self->log->debug("Node: " . Dumper($node));

    $self->render(node => $node, node_id => $node_id);
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