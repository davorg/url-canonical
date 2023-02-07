package URL::Canonical;

use strict;
use warnings;

use Moo;
use Types::Standard qw[InstanceOf];
use URI;
use LWP::UserAgent;
use HTTP::Exception;
use Web::Query;

has url => (
  is => 'ro',
  isa => InstanceOf['URI'],
  required => 1,
);

has canonical_url => (
  is => 'lazy',
  isa => InstanceOf['URI'],
);

sub _build_canonical_url {
  my $self = shift;

  my $resp = $self->ua->get($self->url);

  if ($resp->is_error) {
    HTTP::Exception->throw($resp->code, status_message => $resp->message);
  }

  my $wq = Web::Query->new($resp->content);

  return URI->new($wq->find('link[rel=canonical]')->attr('href'));
}

has ua => (
  is => 'lazy',
  isa => InstanceOf['LWP::UserAgent'],
);

sub _build_ua {
  return LWP::UserAgent->new;
}

1;
