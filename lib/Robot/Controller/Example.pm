package Robot::Controller::Example;
use Mojo::Base 'Mojolicious::Controller';
use Field;
use JSON;

sub welcome {
    my $self = shift;
    $self->render(
        msg => 'Welcome to the Mojolicious real-time web framework!' );
}

sub index {
    my $self = shift;
    $self->render( msg => 'HopHopHop' );
}

sub hop {
    my $self = shift;
    $self->app->log->debug('Websocket opened.');

    $self->on(
        json => sub {
            my ( $c, $hash ) = @_;
            my $action = $hash->{action};
            $self->$action($hash);
        }
    );

    $self->inactivity_timeout(300);
    # $field->mark_as_blocked(3,2);
}

sub create_field {
    my ( $self, $hash ) = @_;
    my $field = Field->new( $hash->{x}, $hash->{y} );
    $self->stash( 'field', $field );
    $self->send(
        encode_json(
            {   action => 'field_was_created',
                field  => $field->{field}
            }
        )
    );
}

sub show_field {
    my ( $self, $hash ) = @_;
    my $field = $self->stash('field');
    $self->send( encode_json( $field->{field} ) );
}

sub mark_as_blocked {
    my ( $self, $data ) = @_;
    use Data::Dumper; warn Dumper ($data);
    my $x = $data->{x};
    my $y = $data->{y};
    $self->stash('field')->mark_as_blocked( $x, $y );
}

sub mark_as_unblocked {
    my ( $self, $data ) = @_;
    my $x = $data->{x};
    my $y = $data->{y};
    $self->stash('field')->mark_as_unblocked( $x, $y );
}

sub mark_start {
    my ( $self, $data ) = @_;
    my $x = $data->{x};
    my $y = $data->{y};
    $self->stash('field')->map( $x, $y );
}

sub go {
    my ( $self, $data ) = @_;
    my $x    = $data->{x};
    my $y    = $data->{y};
    my $path = $self->stash('field')->go( $x, $y );
    my $data = {
        action => 'path',
        path  => $path
    };
    use Data::Dumper; warn Dumper ($data);
    $self->send( encode_json($data) );
}

1;
