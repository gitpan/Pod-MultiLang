## ----------------------------------------------------------------------------
#  Pod::MultiLang::Dict
# -----------------------------------------------------------------------------
# Mastering programed by YAMASHINA Hio
#
# Copyright 2003 YMIRLINK,Inc.
# -----------------------------------------------------------------------------
# $Id: Dict.pm,v 1.3 2003/09/13 05:52:44 hio Exp $
# -----------------------------------------------------------------------------
package Pod::MultiLang::Dict;
use strict;
use vars qw($VERSION);
BEGIN{
$VERSION = '0.01';
}

use Carp;
use vars qw(%STATIC_TABLE %DICT);

# -----------------------------------------------------------------------------
# new()
#   とくになにもしないけど^^;;
#
sub new
{
  my $pkg = shift;
  my $this = bless \$pkg,$pkg;
  $this;
}

# -----------------------------------------------------------------------------
# Pod::MultiLang::Dict->load_dict([@langs]);
#   失敗時には die.
#   辞書をロード.
#   ロード済みなら単純に無視される.
#
sub load_dict
{
  my $pkg = shift;
  @_ or return;
  foreach my $lang(UNIVERSAL::isa($_[0],'ARRAY')?@{$_[0]}:@_)
  {
    $lang =~ /^[a-zA-Z_]\w+([\.\-]\w+)*$/ or croak "invalid lang [$lang]";
    exists($DICT{$lang}) and next;
    my $pkg = "Pod::MultiLang::Dict::$lang";
    $pkg =~ tr/\.\-/__/;
    $DICT{$lang} = $pkg;
    my $eval = "use $pkg;";
    eval $eval;
    $@ && $lang ne 'en' and croak $@;
    if( $pkg->can("static_table") )
    {
      my $table = $pkg->static_table();
      $STATIC_TABLE{$lang} = $table;
    }
  }
}

# -----------------------------------------------------------------------------
# @text = Pod::MultiLang::Dict->find_word([@langs],$text);
#
sub find_word
{
  my $pkg = shift;
  my $langs = shift;
  my $origtext = shift;
  my $text = uc($origtext);
  my @inparts = split(/\s+(AND|&)\s+/,$text);
  my @text;
  foreach my $lang (@$langs)
  {
    my @parts;
    if( @inparts>1 && !exists($STATIC_TABLE{$lang}{AND}) )
    {
      push(@text,undef);
      next;
    }
    foreach my $text (@inparts)
    {
      if( exists($STATIC_TABLE{$lang}{$text}) )
      {
        push(@parts,$STATIC_TABLE{$lang}{$text});
        next;
      }
      if( $text eq '&' )
      {
        if( exists($STATIC_TABLE{$lang}{AND}) )
        {
          push(@parts,$STATIC_TABLE{$lang}{AND});
        }else
        {
          push(@parts,$text);
        }
        next;
      }
      
      my $chk;
      # 複数形っぽかったら単数形探してみる
      #
      if( ($chk = $text) =~ s/S$// && exists($STATIC_TABLE{$lang}{$chk}) )
      {
        push(@parts,$STATIC_TABLE{$lang}{$chk});
        next;
      }
      # 複数形にして探してみる
      #
      $chk = $text.($text=~/[SX]$/?'ES':'S');
      if( exists($STATIC_TABLE{$lang}{$chk}) )
      {
        push(@parts,$STATIC_TABLE{$lang}{$chk});
        next;
      }
      @parts = ();
      last;
    }
    push(@text,@parts?join('',@parts):$lang eq 'en'?$origtext:undef);
  }
  #print "[$text]\n";
  #map{print "  [$_]\n"}@text;
  @text;
}

# -----------------------------------------------------------------------------
# $text = $pkg->make_linktext($lang,$name,$section);
# 
sub make_linktext
{
  my ($pkg,$lang,$name,$section) = @_;
  my $impl = $pkg.'::'.$lang;
  if( UNIVERSAL::can($impl,'make_linktext') )
  {
    $impl->make_linktext($lang,$name,$section);
  }else
  {
    $name
      ? $section ? qq($name/"$section") : $name
      : $section ? qq("$section") : undef;
  }
}

1;
__END__
# -----------------------------------------------------------------------------
# End Of File.
# -----------------------------------------------------------------------------
