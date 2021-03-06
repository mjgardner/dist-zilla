use strict;
use warnings;
use Test::More 0.88;

use lib 't/lib';

use autodie;
use Test::DZil;

my $tzil = Dist::Zilla::Tester->from_config(
  { dist_root => 'corpus/DZT' },
  {
    add_files => {
      'source/dist.ini' => simple_ini(
        [
          GenerateFile => Dingo => {
            filename    => 'txt/dingo.txt',
            is_template => 1,
            content     => [
              'Welcome to Dingo Kidneys {{ $dist->version }}',
              'Generated by {{ $plugin->VERSION || 0 }}',
            ],
          }
        ],
        [
          GenerateFile => Kidneys => {
            filename    => 'txt/dingo.tmpl',
            content     => [
              'Welcome to Dingo Kidneys {{ $dist->version }}',
              'Generated by {{ $plugin->VERSION || 0 }}',
            ],
          }
        ],
      )
    },
  },
);

$tzil->build;

{
  my $contents = $tzil->slurp_file('build/txt/dingo.txt');

  like(
    $contents,
    qr{Kidneys 0.001\n}sm,
    'we render $dist stuff into dingo.txt',
  );

  like(
    $contents,
    qr{^Generated by \d}sm,
    'we render $plugin stuff into dingo.txt',
  );
}

{
  my $contents = $tzil->slurp_file('build/txt/dingo.tmpl');

  like(
    $contents,
    qr/Kidneys {{ \$dist->version }}\n/sm,
    'we include template literals into dingo.tmpl',
  );

  like(
    $contents,
    qr/^Generated by {{ \$plugin->VERSION/sm,
    'we include template literals into dingo.tmpl (line 2)',
  );
}

done_testing;
