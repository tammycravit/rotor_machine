#!/usr/bin/perl -w
############################################################################
# resolve_coverage.pl: Parse the output of a Ruby simplecov_erb text file,
#                      and generate a report with code context for missed
#                      lines.
#
# Version 1.00, 2018-06-15, tammycravit@me.com
############################################################################

use File::Spec;
use File::Basename;
use File::Slurp;
use Term::ANSIColor qw(:constants);
use Cwd;

####################
# CONFIGURATION CONSTANTS
####################

$FILE_PREFIX              = "";
$FILE_SUFFIX              = "";
$FILENAME_COLOR           = BLUE;
$EXAMPLE_PREFIX           = "";
$EXAMPLE_SUFFIX           = "\n";
$CONTEXT_SIZE             = 2;
$CONTEXT_UNCOVERED_MARKER = "->";
$CONTEXT_UNCOVERED_COLOR  = RED;

####################
# Script begins here
####################

sub generate_file_context
{
  my ($filename, $lines_list) = @_;
  $filename =~ s@//@/@g;

  my @lines = @$lines_list;
  @content = read_file($filename, chomp => 1);

  if (length $FILE_PREFIX) { print $FILE_PREFIX; }

  print
    BOLD, WHITE, "*** ", RESET
    BOLD, $FILENAME_COLOR, $filename, RESET,
    WHITE, " ($#content lines)", RESET,
    "\n";
  print "\n";

  foreach my $which_line (@lines)
  {
    $which_line--;
    if (length $EXAMPLE_PREFIX) { print $EXAMPLE_PREFIX; }

    for ($i = $which_line - $CONTEXT_SIZE; $i <= $which_line + $CONTEXT_SIZE; $i++)
    {
      if ($i <= $#content)
      {
        my $color = ($i == $which_line ? $CONTEXT_UNCOVERED_COLOR : WHITE);
        my $number_color = CYAN;
        my $reset = RESET;
        printf "%s%s%s%5.0d:%s %s%s\n",
          $color,
          ($i == $which_line ? $CONTEXT_UNCOVERED_MARKER : (" " x length($CONTEXT_UNCOVERED_MARKER))),
          $number_color,
          $i+1,
          $color,
          $content[$i],
          $reset;
      }
    }

    if (length $EXAMPLE_SUFFIX) { print $EXAMPLE_SUFFIX; }
  }

  if (length $FILE_SUFFIX) { print $FILE_SUFFIX; }
}

$coverage_file = File::Spec->rel2abs($ARGV[0]);
$project_root  = dirname($coverage_file);
$project_root  = dirname($project_root);

print "****************************************************************************\n";
print "* resolve_coverage.pl: Parse a simplecov-erb coverage report and generate  *\n";
print "*                      contextual code snippets for uncovered lines.       *\n";
print "*                                                                          *\n";
print "* Version 1.00, 2018-06-15, Tammy Cravit, tammycravit\@me.com               *\n";
print "****************************************************************************\n";
print "\n";
print BOLD, MAGENTA, "==> Coverage file: ", RESET, MAGENTA, $coverage_file, "\n", RESET;
print BOLD, MAGENTA, "==> Project root : ", RESET, MAGENTA, $project_root, "\n", RESET;
print BOLD, MAGENTA, "==> Context lines: ", RESET, MAGENTA, $CONTEXT_SIZE, "\n", RESET;
print "\n";

die "Usage: $0 coverage_file.txt\n" unless (-f $coverage_file);

open (COVERAGE, $coverage_file) || die;
while (<COVERAGE>)
{
  chomp;
  if ($_ =~ m/^(\S+)\b.*?missed:\s?([0123456789,]+)/)
  {
    $filename = $1;
    @lines = split(/,/, $2);
    generate_file_context("$project_root/$filename", \@lines);
  }
}
close (COVERAGE);
exit 0;

