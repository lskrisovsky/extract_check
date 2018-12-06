#!/usr/bin/perl
use utf8;
use Config;
use warnings;
use XML::Simple;
use Cwd;

#############################
## GLOBAL VARIABLES  ########
#############################
my $p='';
my $p_name='';
my $p_value='';
my $p_header='';
my $p_separator='';
my $p_folder='';
my $p_filemask='';

#############################
## CORE PRAGRAM  ############
#############################
# ev.pl header=0 separator="|" folder=f:\_Work\ING\Profile7\extracts\ filemask=*.dat
  #############################
  # INITIALIZING
  foreach (@ARGV) {
    $p = $_;
    $p_name = &get_parameter_name($p);
    $p_value = &get_parameter_value($p);
    if($p_name eq 'header') {$p_header = $p_value};
    if($p_name eq 'separator') {$p_separator = $p_value};
    if($p_name eq 'folder') {$p_folder = $p_value};
    if($p_name eq 'filemask') {$p_filemask = $p_value};
  }
#  &get_cls;
  print "#######################################\n";
  print "# INITIALIZING - ".&get_current_timestamp." ##\n";
  print "#######################################\n";
  print "# PARAMETERS\n";
  print "  Extract with header:   $p_header\n";
  print "  Columns separator:     $p_separator\n";
  print "  Extract folder:        $p_folder\n";
  print "  Filemask:              $p_filemask\n";
  #############################

@files = &get_file_list($p_folder, $p_filemask);
my $file_cnt = scalar @files;
my $file_row_cnt;
my $file_col_cnt;
my $file_col_list;
my $row_col_cnt_err = 0;
print "  Files in folder:       $file_cnt\n\n";
print "# FILES\n";
for (my $act_file=0; $act_file < $file_cnt; $act_file++) {
  $files[$act_file] =~ s/\///g;
#  $file_row_cnt = &s_open_file($files[$act_file], $p_header);
  ($file_row_cnt, $file_col_cnt, $file_col_list, $row_col_cnt_err) = &s_open_file($files[$act_file], $p_header);      
  @file_col_alist = split("\Q$p_separator", $file_col_list);
  print "  ".&get_filename($files[$act_file])."\n";
  print "    row_count:   $file_row_cnt\n";
  print "    col_count:   $file_col_cnt\n";
  print "    err_count:   $row_col_cnt_err\n";
  if($p_header == 1) {
    print "    col_list:    \n";
    foreach (@file_col_alist) {
      print "      $_\n";
    }
  }
}

#############################  

  
#############################
## SUB-PRAGRAMS  ############
#############################
sub get_split_string($$) {
  my ($p_string, $p_separator) = @_;
  my @ss = split('\$p_separator', $p_string);
  return @ss;
}

sub get_filename($) {
  my ($p_filepath) = @_;
  return substr($p_filepath, rindex($p_filepath, '\\') + 1)
}

sub s_open_file($$) {
  my ($p_filename, $p_header, $p_col_cnt) = @_; 
  my $cols = 0;
  my $err_col_cnt = 0;
  my @file_attr = (0, 0);
  my $column_list;
  open(my $o_file, '<:encoding(UTF-8)', $p_filename) or die "Could not open file '$p_filename' $!";
    my($lines) = (0);
    while(my $row = <$o_file>) {
      $lines++;
      if($lines == 1) {
        $cols = &get_separators_cnt($row, $p_separator);
        $column_list = $row;
      }
      if($lines > 1) {
        $row_cols = &get_separators_cnt($row, $p_separator);
        if($row_cols != $cols) {
          $err_col_cnt++;
        }
      }      
    }    
  close $o_file;
  @file_attr = ($lines, $cols, $column_list, $err_col_cnt);
  return @file_attr;
}

sub get_parameter_name($) {
  # parametr name
  my $p_name = substr($_, 0, index($_, '='));  
  return $p_name;  
}

sub get_parameter_value($) {
  # parametr name  
  my $p_value = substr($_, index($_, '=') + 1);  
  return $p_value;  
}

sub get_current_timestamp {
  my ($sec, $min, $hour, $mday, $mon, $year) = localtime;
  my $s = sprintf("%04d-%02d-%02d %02d:%02d:%02d", $year+1900, $mon+1, $mday, $hour, $min, $sec);
  return $s;
}

sub get_separators_cnt($$) {
  my ($p_string, $p_separator) = @_;
  my @cnt = ($p_string =~ /\Q$p_separator/g);
  my $count = @cnt + 1;
  return $count;
}

sub get_cls {
  print "\033[2J";
  print "\033[0;0H";
}

sub get_file_list($$) {
  # 1.argument - string (mask file)
  # 2.argument - string (subfolder)
  my ($directory, $filemask) = @_;  
  my @files = glob "$directory/$filemask";
  return @files;
}

#############################  
