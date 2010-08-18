#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 1;                      # last test to print

use lib "t/lib";
use Schema;

  my $schema = get_schema();
  $schema->deploy;
  my $map = <<'EOMAP';
0.1--0.1.2--0.1.2.3--0.1.2.3.4
\                  `-0.1.2.3.5
 `-0.1.6
0.7
0.8
EOMAP
  $schema->resultset('Test')->create_from_map($map);
  ok($schema->resultset('Test')->map_exists($map), 'map exists');

  done_testing();

sub get_schema {
  my $db_dir = File::Spec->catdir('t', 'var');
  my $db_file = File::Spec->catfile($db_dir, 'test.db');
  unlink $db_file if -e $db_file;
  unlink "${db_file}-journal" if -e "${db_file}-journal";
  mkdir $db_dir unless -d $db_dir;

  my $dsn = "dbi:SQLite:$db_file";

  return Schema->connect("dbi:SQLite:$db_file");
}

#!/usr/bin/perl
#
#use strict;
#use warnings;
#
#use FindBin;
#use lib "$FindBin::Bin/lib", "$FindBin::Bin/t/lib";
#
#use Test::Most tests => 19;
#use TestMessages;
#
#

