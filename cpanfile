requires 'perl', '5.42.0';
requires 'Data::Dump', '1.25';
requires 'HTTP::Message', '7.01';
requires 'Moo', '2.005005';
requires 'Mojolicious', '9.42';
requires 'namespace::autoclean', '0.31';
requires 'Role::Tiny', '2.002004';
requires 'Type::Tiny', '2.008004';

on 'test' => sub {
  requires 'Test::Class::Most', '0.08';
  requires 'Test::Lib', '0.003';
};
