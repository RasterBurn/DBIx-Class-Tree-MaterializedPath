#!/usr/bin/perl

use strict;
use warnings;

use Test::More;                      # last test to print
use Test::Differences;

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

  my %nodes = map { $_->id => $_ } $schema->resultset('Test')->search({}, { order_by => 'id' } );

  subtest 'parent' => sub {
    is($nodes{2}->parent->id, 1, "2's parent is 1");
    is($nodes{3}->parent->id, 2, "3's parent is 2");
    is($nodes{4}->parent->id, 3, "4's parent is 3");
    is($nodes{5}->parent->id, 3, "5's parent is 3");
    is($nodes{6}->parent->id, 1, "6's parent is 1");

    # TODO parents
    done_testing();
  };

  subtest 'roots' => sub {
    ok($nodes{1}->is_root, "1 is a root node");
    ok(!$nodes{2}->is_root, "2 is not a root node");
    ok(!$nodes{3}->is_root, "3 is not a root node");
    ok(!$nodes{4}->is_root, "4 is not a root node");
    ok(!$nodes{5}->is_root, "5 is not a root node");
    ok(!$nodes{6}->is_root, "6 is not a root node");
    ok($nodes{7}->is_root, "7 is a root node");
    ok($nodes{8}->is_root, "8 is a root node");
  };

  subtest 'leafs' => sub {
    ok(!$nodes{1}->is_leaf, "1 is not a leaf node");
    ok(!$nodes{2}->is_leaf, "2 is not a leaf node");
    ok(!$nodes{3}->is_leaf, "3 is not a leaf node");
    ok($nodes{4}->is_leaf, "4 is a leaf node");
    ok($nodes{5}->is_leaf, "5 is a leaf node");
    ok($nodes{6}->is_leaf, "6 is a leaf node");
    ok($nodes{7}->is_leaf, "7 is a leaf node");
    ok($nodes{8}->is_leaf, "8 is a leaf node");
  };


  subtest 'branches' => sub {
    ok(!$nodes{1}->is_branch, "1 is not a branch node");
    ok($nodes{2}->is_branch, "2 is a branch node");
    ok($nodes{3}->is_branch, "3 is a branch node");
    ok(!$nodes{4}->is_branch, "4 is not a branch node");
    ok(!$nodes{5}->is_branch, "5 is not a branch node");
    ok(!$nodes{6}->is_branch, "6 is not a branch node");
    ok(!$nodes{7}->is_branch, "7 is not a branch node");
    ok(!$nodes{8}->is_branch, "8 is not a branch node");

    done_testing();
  };

  subtest 'descendants' => sub {
    # TODO has_descendant
    ok($nodes{1}->has_descendant, "1 has descendant");
    ok($nodes{2}->has_descendant, "2 has descendant");
    ok($nodes{3}->has_descendant, "3 has descendant");
    ok(!$nodes{4}->has_descendant, "4 doesn't have a descendant");
    ok(!$nodes{5}->has_descendant, "5 doesn't have a descendant");
    ok(!$nodes{6}->has_descendant, "6 doesn't have a descendant");
    ok(!$nodes{7}->has_descendant, "7 doesn't have a descendant");
    ok(!$nodes{8}->has_descendant, "8 doesn't have a descendant");

#    {
#      use DBIx::Class::ResultClass::HashRefInflator;
#      my $rs = $schema->resultset('Test');
#      $rs->result_class('DBIx::Class::ResultClass::HashRefInflator');
#      my @hashrefs = $rs->search({});
#      use Data::Dump qw/dump/;
#      diag dump(\@hashrefs);
#    }
    # TDOO descendants
    my %descendants = ();
    foreach my $node (values %nodes) {
      my @desc_ids = sort map { $_->id } $node->descendants;
#      use Data::Dump qw/dump/;
#      diag sprintf("descendants of %s are %s", $node->id, dump(\@desc_ids));
      $descendants{$node->id} = \@desc_ids;
    }
    eq_or_diff($descendants{1}, [2,3,4,5,6] ,"2,3,4,5 are descendants of 1");

    done_testing();
  };

  subtest 'ancestors' => sub {
  };

  subtest 'children' => sub {
  };

  subtest 'siblings' => sub {
  };

  subtest 'attach_child' => sub {
  };

  subtest 'attach_siblings' => sub {
  };

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

