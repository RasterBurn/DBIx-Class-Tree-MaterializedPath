use strict;
use warnings;
use lib 't/lib';

#
# These tests and the libraries it uses
# are taken from DBIx::Class::Tree::AdjacencyList
# in order to prove compatibility
#

use Test::More;

BEGIN {   # This must happen before the schema is loaded

  require TreeTest::Schema::Node;

  TreeTest::Schema::Node->load_components(qw(
    Tree::MaterializedPath
  ));
}

use TreeTest;

my $tests = TreeTest::count_tests();
plan tests => $tests;
TreeTest::run_tests();

1;
