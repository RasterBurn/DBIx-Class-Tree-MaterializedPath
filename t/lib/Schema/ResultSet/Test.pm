package Schema::ResultSet::Test;
use base qw/DBIx::Class::ResultSet/;
use Carp;
use Test::More;

sub _paths_from_map {
  my $self = shift;
  my $map = shift;
  my @paths = ();
  while ($map) {
    $map =~ s/[^\d\.]*//; # bye bye junk
    $map =~ s/([0-9\.]+)// && do {
      push @paths, $1;
    };
  }
  return @paths;
}
sub create_from_map {
  my $self = shift;
  my $map  = shift;

  my @paths = $self->_paths_from_map($map);

  my %node_cache = ();

  foreach my $path (@paths) {
    my @node_ids = split(/\./, $path);
    my $node_id = $node_ids[-1];
    my $parent_node_id = $node_ids[-2];
    
    my $params = { id => $node_id, name => "node $node_id" };
    my $node = $self->create($params);
    $node->parent($node_cache{$parent_node_id}) if exists $node_cache{$parent_node_id};
    $node_cache{$node_id} = $node;
    
    
  }
}

sub map_exists {
  my $self = shift;
  my $map  = shift;

  my @paths = $self->_paths_from_map($map);

  eval {
    foreach my $path (@paths) {
      my @node_ids = split(/\./, $path);
      my $node_id = $node_ids[-1];
      my $node = $self->find($node_id);
      my $matpath = join(q{.}, @node_ids[0..$#node_ids-1]);
      $matpath = 0 if scalar @node_ids == 1; # root nodes have 0 matpath
      $matpath .= ".";
      die "Node $node_id not found" unless defined $node;
      my $found_path = $node->materialized_path;
      die "Node $node_id is expected to have path $matpath, but has path $found_path" if $found_path ne $matpath;
    }
  };
  if (my $error = $@) {
    Test::More::diag($error);
    return 0;
  }
  return 1;
}


1;
