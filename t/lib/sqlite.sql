
CREATE TABLE nodes (
    node_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name STRING,
    materialized_path STRING,
    depth INTEGER,
    position INTEGER,
    lft INTEGER,
    rgt INTEGER
);

