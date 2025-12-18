package MonkWorld::Role::ApiClient;
use v5.40;
use Mojo::Base -role, -signatures;

sub api_url ($self) {
    return $ENV{MONKWORLD_API_URL} // $self->config->{api}{url};
}

sub get_sitemap ($self) {
    state $sitemap = do {
        my $res = $self->app->ua->get($self->api_url)->result;
        if (!$res->is_success) {
            my $message = "Failed to fetch sitemap: " . $res->message;
            $self->log->error($message);
            die $message;
        }
        $res->json;
    };
    return $sitemap;
}
