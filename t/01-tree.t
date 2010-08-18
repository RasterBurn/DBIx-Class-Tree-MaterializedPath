#!/usr/bin/perl

use strict;
use warnings;

use Test::More;                      # last test to print
use Test::Differences;
use Test::Exception;

use lib "t/lib";
use Schema;

  my $schema = get_schema();
  $schema->deploy;
  my $map = <<'EOMAP';
0.1--0.1.2--0.1.2.3--0.1.2.3.4
   \               `-0.1.2.3.5
    `0.1.6
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

    done_testing();
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

    done_testing();
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
    ok($nodes{1}->has_descendant($_), "1 has descendant $_") for (2,3,4,5,6);
    ok($nodes{2}->has_descendant($_), "2 has descendant $_") for (3,4,5);
    ok($nodes{3}->has_descendant($_), "1 has descendant $_") for (4,5);

    my %descendants = ();
    foreach my $node (values %nodes) {
      my @desc_ids = sort map { $_->id } $node->descendants;
      $descendants{$node->id} = \@desc_ids;
    }
    eq_or_diff($descendants{1}, [2,3,4,5,6] ,"2,3,4,5 are descendants of 1");
    eq_or_diff($descendants{2}, [3,4,5] ,"3,4,5 are descendants of 2");
    eq_or_diff($descendants{3}, [4,5] ,"4,5 are descendants of 3");
    eq_or_diff($descendants{4}, [] ,"no descendants of 4");
    eq_or_diff($descendants{5}, [] ,"no descendants of 5");
    eq_or_diff($descendants{6}, [] ,"no descendants of 6");
    eq_or_diff($descendants{7}, [] ,"no descendants of 7");
    eq_or_diff($descendants{8}, [] ,"no descendants of 8");

    done_testing();
  };


  subtest 'ancestors' => sub {
    my %ancestors = ();
    foreach my $node (values %nodes) {
      my @anc_ids = sort map { $_->id } $node->ancestors;
      $ancestors{$node->id} = \@anc_ids;
    }
    eq_or_diff($ancestors{1}, [], "no ancestors of 1");
    eq_or_diff($ancestors{2}, [1], "1 is ancestor of 2");
    eq_or_diff($ancestors{3}, [1,2], "1,2 are ancestors of 3");
    eq_or_diff($ancestors{4}, [1,2,3], "1,2,3 are ancestors of 4");
    eq_or_diff($ancestors{5}, [1,2,3], "1,2,3 are ancestors of 5");
    eq_or_diff($ancestors{6}, [1], "1 is ancestor of 6");
    eq_or_diff($ancestors{7}, [], "no ancestors of 7");
    eq_or_diff($ancestors{8}, [], "no ancestors of 8");

    done_testing();
  };

  subtest 'children' => sub {
    my %children = ();
    foreach my $node (values %nodes) {
      my @child_ids = sort map { $_->id } $node->children;
      $children{$node->id} = \@child_ids;
    }
    eq_or_diff($children{1}, [2,6], "2,6 are children of 1");
    eq_or_diff($children{2}, [3], "3 is child of 2");
    eq_or_diff($children{3}, [4,5], "4,5 are children of 3");
    eq_or_diff($children{4}, [], "no children of 4");
    eq_or_diff($children{5}, [], "no children of 5");
    eq_or_diff($children{6}, [], "no children of 6");
    eq_or_diff($children{7}, [], "no children of 7");
    eq_or_diff($children{8}, [], "no children of 8");

    done_testing();
  };

  subtest 'siblings' => sub {
    my %siblings = ();
    foreach my $node (values %nodes) {
      my @sib_ids = sort map { $_->id } $node->siblings;
      $siblings{$node->id} = \@sib_ids;
    }
    eq_or_diff($siblings{1}, [7,8], "7,8 are siblings of 1");
    eq_or_diff($siblings{2}, [6], "6 is sibling of 2");
    eq_or_diff($siblings{3}, [], "no siblings of 3");
    eq_or_diff($siblings{4}, [5], "5 is sibling of 4");
    eq_or_diff($siblings{5}, [4], "4 is sibling of 5");
    eq_or_diff($siblings{6}, [2], "2 is sibling of 6");
    eq_or_diff($siblings{7}, [1,8], "1,8 are siblings of 7");
    eq_or_diff($siblings{8}, [1,7], "1,7 are siblings of 8");

    done_testing();
  };

  subtest 'attach_child' => sub {
    $nodes{7}->attach_child($nodes{8});
    ok($schema->resultset('Test')->map_exists(<<'EOMAP'), '8 becomes child of 7');
0.1--0.1.2--0.1.2.3--0.1.2.3.4
   \               `-0.1.2.3.5
    `0.1.6
0.7--0.7.8
EOMAP

    $nodes{6}->attach_child($nodes{7});
    ok($schema->resultset('Test')->map_exists(<<'EOMAP'), '7 becomes child of 6');
0.1--0.1.2--0.1.2.3--0.1.2.3.4
   \               `-0.1.2.3.5
    `0.1.6--0.1.6.7--0.1.6.7.8
EOMAP
    
    throws_ok { $nodes{6}->attach_child(1337) } qr/Cannot find child node by id/, 'bad id caught';
    throws_ok { $nodes{2}->attach_child($nodes{1}) } qr/Cannot make an ancestor node the child of the node/, 'ancestor loop caught';
    throws_ok { $nodes{2}->attach_child($nodes{2}) } qr/Cannot make a node the parent of itself/, 'self loop caught';

    $nodes{9} = $schema->resultset('Test')->create({ id => 9, name => 'node 9' });
    $nodes{9}->attach_child($nodes{1});
     ok($schema->resultset('Test')->map_exists(<<'EOMAP'), '9 becomes new root');
0.9--0.9.1--0.9.1.2--0.9.1.2.3--0.9.1.2.3.4
          \                   `-0.9.1.2.3.5
           `0.9.1.6--0.9.1.6.7--0.9.1.6.7.8
EOMAP
   

    done_testing();
  };

  subtest 'attach_sibling' => sub {

    done_testing();
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

