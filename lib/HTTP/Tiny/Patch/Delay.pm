package HTTP::Tiny::Patch::Delay;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;
use Log::ger;

use Module::Patch qw();
use base qw(Module::Patch);

use Time::HiRes qw(sleep);

our %config;

my $seen;
my $p_request = sub {
    my $ctx = shift;
    my $orig = $ctx->{orig};

    if ($seen++) {
        my $secs = $config{-between_request} // 1;
        log_trace "Sleeping %.1f second(s) between LWP::UserAgent request ...",
            $secs;
        sleep $secs;
    }
    $ctx->{orig}->(@_);
};

sub patch_data {
    return {
        v => 3,
        config => {
            -between_request => {
                schema  => 'nonnegnum*',
                default => 1,
            },
        },
        patches => [
            {
                action      => 'wrap',
                mod_version => qr/^0\.*/,
                sub_name    => 'request',
                code        => $p_request,
            },
        ],
    };
}

1;
# ABSTRACT: Add sleep() between requests to slow down

=for Pod::Coverage ^(patch_data)$

=head1 SYNOPSIS

From Perl:

 use HTTP::Tiny::Patch::Delay
     # -between_requests => 1.5, # optional, default is 1
 ;

 my $res  = HTTP::Tiny->new->get("http://www.example.com/");


=head1 DESCRIPTION

This patch adds sleep() between L<HTTP::Tiny> requests.


=head1 CONFIGURATION

=head2 -between_request

Float. Default is 1. Number of seconds to sleep() after each request. Uses
L<Time::HiRes> so you can include fractions of a second, e.g. 0.1 or 1.5.


=head1 FAQ


=head1 ENVIRONMENT


=head1 SEE ALSO

L<LWP::UserAgent::Patch::Delay>

L<HTTP::Tiny>

=cut
