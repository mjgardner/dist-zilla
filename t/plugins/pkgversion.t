use strict;
use warnings;
use Test::More 0.88;

use lib 't/lib';

use autodie;
use Test::DZil;

my $with_version = '
package DZT::WVer;
our $VERSION = 1.234;
1;
';

my $two_packages = '
package DZT::TP1;

package DZT::TP2;

1;
';

my $script_pkg = '
#!/usr/bin/perl

package DZT::Script;
';

my $tzil = Dist::Zilla::Tester->from_config(
  { dist_root => 'corpus/DZT' },
  {
    add_files => {
      'source/lib/DZT/TP1.pm'    => $two_packages,
      'source/lib/DZT/WVer.pm'   => $with_version,
      'source/bin/script.pl'     => $script_pkg,
      'source/bin/script_ver.pl' => $script_pkg . "our \$VERSION = 1.234;\n",
      'source/dist.ini' => simple_ini('GatherDir', 'PkgVersion', 'ExecDir'),
    },
  },
);

$tzil->build;

my $dzt_sample = $tzil->slurp_file('build/lib/DZT/Sample.pm');
like(
  $dzt_sample,
  qr{^\s*\$\QDZT::Sample::VERSION = '0.001';\E$}m,
  "added version to DZT::Sample",
);

my $dzt_tp1 = $tzil->slurp_file('build/lib/DZT/TP1.pm');
like(
  $dzt_tp1,
  qr{^\s*\$\QDZT::TP1::VERSION = '0.001';\E$}m,
  "added version to DZT::TP1",
);

like(
  $dzt_tp1,
  qr{^\s*\$\QDZT::TP2::VERSION = '0.001';\E$}m,
  "added version to DZT::TP2",
);

my $dzt_wver = $tzil->slurp_file('build/lib/DZT/WVer.pm');
unlike(
  $dzt_wver,
  qr{^\s*\$\QDZT::WVer::VERSION = '0.001';\E$}m,
  "*not* added to DZT::WVer; we have one already",
);

my $dzt_script = $tzil->slurp_file('build/bin/script.pl');
like(
    $dzt_script,
    qr{^\s*\$\QDZT::Script::VERSION = '0.001';\E$}m,
    "added version to DZT::Script",
);

my $script_wver = $tzil->slurp_file('build/bin/script_ver.pl');
unlike(
    $script_wver,
    qr{^\s*\$\QDZT::WVer::VERSION = '0.001';\E$}m,
    "*not* added to versioned DZT::Script; we have one already",
);

ok(
  grep({ m(skipping lib/DZT/WVer\.pm: assigns to \$VERSION) }
    @{ $tzil->log_messages }),
  "we report the reason for no updateing WVer",
);

done_testing;

