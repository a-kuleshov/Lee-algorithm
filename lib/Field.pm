package Field;
use strict;
use warnings;

use constant UNMARKED => -2;
use constant BLOCKED  => -1;


sub new {
    my ($class, $diag) = shift;
    my ( $N, $M ) = @_;
    $class = ref $class if ref $class;
    my $mark_locality = [
        [-1, 0], [ 1, 0],  [ 0, -1],  [ 0, 1],
    ];
    push @$mark_locality,  [-1, 1], [ 1, -1], [ 1, 1], [-1, -1] if $diag;
    my $self = bless {
        size => { x => $N, y => $M },
        mark_locality => $mark_locality,
    }, $class;
    for ( my $i = 0; $i < $N; $i++ ) {
        for ( my $j = 0; $j < $M; $j++ ) {
            $self->{field}[$i][$j] = UNMARKED;
        }
    }
    return $self;
}

sub print {
    my ($self) = @_;
    for ( my $j = $self->{size}{y} - 1; $j >= 0; $j-- ) {
        for ( my $i = 0; $i < $self->{size}{x}; $i++ ) {
            printf "%02d ", $self->{field}[$i][$j];
        }
        print "\n\n";
    }
}

sub dump {
    my ($self) = @_;
    return $self->{field};
};

sub mark_as_blocked {
    my ( $self, $x, $y ) = @_;
    $self->{field}[$x][$y] = BLOCKED;
}

sub mark_as_unblocked {
    my ( $self, $x, $y ) = @_;
    $self->{field}[$x][$y] = UNMARKED;
}

sub map {
    my ( $self, $from_x, $from_y ) = @_;
    $self->{field}[$from_x][$from_y] = 0;
    $self->push( [$from_x, $from_y, 0] );
    while (@{$self->{queue}}) {
        my $to_be_marked_around = $self->shift;
        foreach my $locality (@{$self->{mark_locality}}) {
            my $x_to_be_marked = $to_be_marked_around->[0] + $locality->[0];
            my $y_to_be_marked = $to_be_marked_around->[1] + $locality->[1];
            my $distance = $to_be_marked_around->[2] + 1;

            if (
                $x_to_be_marked >= 0 &&
                $y_to_be_marked >= 0 &&
                $y_to_be_marked < $self->{size}{y} &&
                $x_to_be_marked < $self->{size}{x} &&
                $self->{field}->[$x_to_be_marked][$y_to_be_marked] == UNMARKED
            ) {
                # warn $self->{field}->[$x_to_be_marked][$y_to_be_marked];
                $self->{field}->[$x_to_be_marked][$y_to_be_marked] = $distance;
                $self->push( [$x_to_be_marked, $y_to_be_marked, $distance]);
            }
        };
        # use Data::Dumper; warn Dumper ($self->{queue});
    }
}

sub go {
    my ( $self, $to_x, $to_y ) = @_;
    my $current_cell = [$to_x, $to_y];
    my $path = [];
        while ($self->{field}->[$current_cell->[0]][$current_cell->[1]] != 0) {
        my $min = $self->find_min($current_cell);
        $current_cell = [ $min->[0] + $current_cell->[0], $min->[1] + $current_cell->[1]];
        push @$path, $current_cell;
    }
    $self->{field}->[$_->[0]][$_->[1]] = 99 for @$path;
    return $path;
}

sub find_min {
    my ($self, $main_cell) = @_;
    my $min = [0,0];
    foreach my $locality (@{$self->{mark_locality}}) {
        my $x_to_be_checked = $main_cell->[0] + $locality->[0];
        my $y_to_be_checked = $main_cell->[1] + $locality->[1];
        if (
            $x_to_be_checked >= 0 &&
            $y_to_be_checked >= 0 &&
            $y_to_be_checked < $self->{size}{y} &&
            $x_to_be_checked < $self->{size}{x} &&
            $self->{field}->[$x_to_be_checked][$y_to_be_checked] != BLOCKED
        ){
            my $current_min_x = $main_cell->[0] + $min->[0];
            my $current_min_y = $main_cell->[1] + $min->[1];
            $min = [@$locality] if $self->{field}->[$x_to_be_checked][$y_to_be_checked] < $self->{field}->[ $current_min_x ][ $current_min_y];
        }
    };
    return $min;

}

sub push {
    my $self = shift;
    push @{$self->{queue}}, @_;
}

sub shift {
    shift @{shift->{queue}};
}

1;
