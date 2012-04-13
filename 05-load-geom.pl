#!/usr/bin/perl -w

# To the extent possible under law, the person who associated CC0
# with this work has waived all copyright and related or neighboring
# rights to this work.
# http://creativecommons.org/publicdomain/zero/1.0/

use strict;
use DBI;
use Data::Dumper;

my $schema = "abs_2011";

my $asgs_unzip_dir = "02-ASGS-UNZIP";

my $delay_sql = "no"; # yes/no (yes writes SQL to file for later execution, no executes sql straight away)

sub do_sql($);

# table_mapping - hash of SHAPE file name to PostgreSQL table name
# volume_mapping - hash of SHAPE file name to dataset ABS publication volume
# src_col_mapping - hash of SHAPE file name to SHAPE file primary key attribute
# dst_col_mapping - hash of SHAPE file name to PostgreSQL primary key attribute
# dst_datatype_mapping - hash of SHAPE file name to PostgreSQL primary key attribute
my %table_mapping;
my %volume_mapping;
my %src_col_mapping;
my %dst_col_mapping;
my %dst_datatype_mapping;
my @ordered_tables;

#FIXME HACK
my @mb_sql;

while (<STDIN>) {
  chomp;
  next if /^#/;
  next if /^\s*$/;

  if (/([^\s]*)\s([^\.]*)\.([^\s]*)\s([^\.]*)\.([^\s]*)\s(.*)/) {
    my $volume = $1;
    my $src_table = $2;
    my $src_column = $3;
    my $dst_table = $4;
    my $dst_column = $5;
    my $dst_datatype = $6;

    # if wildcard character exists, expand it now
    if ($src_table =~ /\*/) {
      my @glob = glob "$asgs_unzip_dir/127005500${volume}_".lc (${src_table})."_csv/";
      for my $g (@glob) {
        if ($g =~ /\/[0-9]*_(.*)_csv/) {
          my $expanded_src_table = $1;
          $volume_mapping{$expanded_src_table} = $volume;
          $table_mapping{$expanded_src_table} = $dst_table;
          $src_col_mapping{$expanded_src_table} = $src_column;
          $dst_col_mapping{$expanded_src_table} = $dst_column;
          $dst_datatype_mapping{$expanded_src_table} = $dst_datatype;
          if (scalar (grep (/^$expanded_src_table$/, @ordered_tables)) == 0) {
            push @ordered_tables, $expanded_src_table;
          }
        }
      }
    }else{
      $volume_mapping{$src_table} = $volume;
      $table_mapping{$src_table} = $dst_table;
      $src_col_mapping{$src_table} = $src_column;
      $dst_col_mapping{$src_table} = $dst_column;
      $dst_datatype_mapping{$src_table} = $dst_datatype;
      if (scalar (grep (/^$src_table$/, @ordered_tables)) == 0) {
        push @ordered_tables, $src_table;
      }
    }
  }else{
    print STDERR "Parse Error: $_\n";
  }
}

my $sql_fh;
if ($delay_sql eq "yes") {
  open ($sql_fh, '>', "05-load-geom-part2.sql") or die $!;
}

# set up database connection
my $dbh = DBI->connect("DBI:Pg:dbname=abs;host=localhost", 'abs', '' , {'RaiseError' => 1, AutoCommit => 1});
my $sth;

for my $src_table (@ordered_tables) {

  my $dst_table = $table_mapping{$src_table};
  my $volume = $volume_mapping{$src_table};

  my $src_col = $src_col_mapping{$src_table};
  my $dst_col = $dst_col_mapping{$src_table};

  my $dst_col_datatype = $dst_datatype_mapping{$src_table};

  my $shp_file = "$asgs_unzip_dir/127005500${volume}_" . lc ($src_table) . "_shape/" . uc ($src_table) . ".shp";

  my $comment_fh;
  if ($delay_sql eq "yes") {
    $comment_fh = $sql_fh;
  }else{
    $comment_fh = <STDOUT>;
  }
  print $comment_fh "-- $shp_file\n";
  print $comment_fh "-- $src_table -> $schema.$dst_table ON \n".
                    "--     $src_col -> ${dst_col}::$dst_col_datatype\n\n";

  print "ogr2ogr $shp_file...\n";
  my $ogr_ret = `ogr2ogr -overwrite -nlt MULTIPOLYGON -select "$src_col" -nln ${dst_table}_ogr -f PostgreSQL PG:"dbname=abs user=abs active_schema=$schema" $shp_file`;
  die "Problem occured using ogr2ogr to load SHAPE file\n" if ($ogr_ret = undef);

  print "psql statements...\n";

  # FIXME HACK
  if ($dst_table eq "mb") {
    push @mb_sql, ("UPDATE $schema.$dst_table SET geom = (SELECT wkb_geometry FROM $schema.${dst_table}_ogr WHERE $schema.$dst_table.$dst_col = $schema.${dst_table}_ogr.${src_col}::$dst_col_datatype);", "UPDATE geometry_columns SET f_geometry_column = 'geom', f_table_name = '$dst_table' WHERE (f_table_schema = '$schema' AND f_table_name = '${dst_table}_ogr');", "DROP TABLE $schema.${dst_table}_ogr CASCADE;", "VACUUM ANALYZE $schema.$dst_table;");
  }else{
    do_sql("UPDATE $schema.$dst_table SET geom = (SELECT wkb_geometry FROM $schema.${dst_table}_ogr WHERE $schema.$dst_table.$dst_col = $schema.${dst_table}_ogr.${src_col}::$dst_col_datatype);");

    do_sql("UPDATE geometry_columns SET f_geometry_column = 'geom', f_table_name = '$dst_table' WHERE (f_table_schema = '$schema' AND f_table_name = '${dst_table}_ogr');");

    do_sql("DROP TABLE $schema.${dst_table}_ogr CASCADE;");

    do_sql("VACUUM ANALYZE $schema.$dst_table;");
  }
  print $comment_fh "\n\n";
}

for my $q (@mb_sql) {
  do_sql($q);
}

$dbh->disconnect or warn $!;

if ($delay_sql eq "yes") {
  close ($sql_fh) or warn $!;
}

print "Success!\n";

sub do_sql($) {
  my ($sql) = @_;
  if ($delay_sql eq "yes") {
    print $sql_fh "$sql\n";
  }else{
    $sth = $dbh->do($sql);
  }
}

