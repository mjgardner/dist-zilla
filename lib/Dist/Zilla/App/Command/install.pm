use strict;
use warnings;
package Dist::Zilla::App::Command::install;
# ABSTRACT: install your dist
use Dist::Zilla::App -command;

=head1 SYNOPSIS

Installs your distribution using a specified command.

    dzil install [--install-command="cmd"]

=cut
sub abstract { 'install your dist' }

=head1 EXAMPLE

    $ dzil install
    $ dzil install --install-command="cpan ."

=cut

sub opt_spec {
  [ 'install-command=s', 'command to run to install (e.g. "cpan .")' ],
}

=head1 OPTIONS

=head2 --install-command

This defines what command to run after building the dist in the dist dir.

Any value that works with L<C<system>|perlfunc/system> is accepted.

If not specified, calls

    perl -MCPAN -einstall "."

=cut

sub execute {
  my ($self, $opt, $arg) = @_;

  $self->zilla->install({
    ($opt->install_command ? (install_command => $opt->install_command) : ()),
  });
}

1;
