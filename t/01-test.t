#!/usr/bin/env perl -w
## ----------------------------------------------------------------------------
#  t/01-test.t
# -----------------------------------------------------------------------------
# Mastering programed by YAMASHINA Hio
#
# Copyright 2004 YAMASHINA Hio
# -----------------------------------------------------------------------------
# $Id: 01-test.t,v 1.1 2004/08/01 04:02:51 hio Exp $
# -----------------------------------------------------------------------------
package Pkg::Module;
use strict;
use Test;
BEGIN { plan tests => 1 }

use Pod::MultiLang::Html;

# -----------------------------------------------------------------------------
# メイン処理
#
&do_work;

sub do_work
{
  my $parser = Pod::MultiLang::Html->new
  (
    langs => [qw(ja en)],
  );
  
  $parser->parse_from_filehandle(TextReader->new(<<EOF),TextWriter->new());
=head1 NAME

test - convert test 
J<< ja;test - 変換テスト >>
EOF
  
  my $o = tied(*{$parser->output_handle()})->get();
  (my $x = $o)=~s/^/#/mg;
  print $x;
  ok($o);
}

# -----------------------------------------------------------------------------
# TextReader/TextWriter
#
package TextReader;
sub new
{
  my ($pkg,$text) = @_;
  my $this = bless[map{$_.$/}split($/,$text)],$pkg;
  $this;
}
sub getline
{
  my $this = shift;
  shift(@$this);
}
package TextWriter;
use Tie::Handle;
use base qw(Tie::Handle);
sub new
{
  my $pkg = shift;
  use vars qw(*HANDLE);
  tie(*HANDLE,$pkg,@_);
  \*HANDLE;
}
sub TIEHANDLE
{
  my ($pkg,$out) = @_;
  my $this = bless[$out],$pkg;
  if( !UNIVERSAL::isa($this->[0],'SCALAR') )
  {
    my $o = !ref($this->[0]) && $this->[0];
    $this->[0] = \$o;
  }
  $this;
}
sub BINMODE
{
  1;
}
sub PRINT
{
  my $this = shift;
  defined($this->[0]) or $this->[0] = '';
  my $o = join(defined($,)?$,:'',@_);
  ${$this->[0]}.=$o;
  length($o);
}
sub get
{
  my $this = shift;
  ${$this->[0]};
}

exit;
__END__
# -----------------------------------------------------------------------------
# End Of File.
# -----------------------------------------------------------------------------
