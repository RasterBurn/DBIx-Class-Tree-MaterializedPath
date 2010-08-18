package Schema::Result::Test;
use base qw/DBIx::Class::Core/;

__PACKAGE__->load_components(qw/Tree::MaterializedPath/);
__PACKAGE__->table('nodes');
__PACKAGE__->add_columns(
  id => { data_type => 'int', is_auto_increment => 1},
  name => { data_type => 'varchar' },
  materialized_path => { data_type => 'varchar' },
  depth => { data_type => 'int' },
);
__PACKAGE__->set_primary_key('id');

1;
