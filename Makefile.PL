
use ExtUtils::MakeMaker;
use strict;

my @MLPODFILES = qw( bin/mlpod2html.mlpod
                     bin/mlpod2pod.mlpod
                     lib/Pod/MultiLang.mlpod
                     lib/Pod/MultiLang/Dict.mlpod
                     lib/Pod/MultiLang/Dict/ja.mlpod
                     lib/Pod/MultiLang/Html.mlpod
                    );

my %ATTR = 
(
  NAME         => 'Pod::MultiLang',
  VERSION_FROM => 'lib/Pod/MultiLang.pm',
  EXE_FILES    => [qw(bin/mlpod2html bin/mlpod2pod bin/mlpod2html.mlpod bin/mlpod2pod.mlpod)],
  depend       => {
                   '.SUFFIXES' => '.mlpod .pod',
                   '.mlpod.pod' => ';$(PERLRUNINST) bin/mlpod2pod $< > $@',
                  },
);
mlpodconvertion(\%ATTR,@MLPODFILES);
WriteMakefile(%ATTR);

# -----------------------------------------------------------------------------
# 
sub mlpodconvertion
{
  my $ATTR = shift;
  my $CP = '$(PERLRUNINST) -MExtUtils::Command -e cp ';
  my @clean_FILES;
  defined($ATTR->{clean}{FILES}) and push(@clean_FILES,$ATTR->{clean}{FILES});
  foreach(@MLPODFILES)
  {
    # *.mlpod           (src)
    # => *.pod          (tmp in srcdir, used for make dist)
    #  => $(INST)*.pod  (blib)
    #   => $(INST)*.man (blib)
    my $mlpod = $_;
    my $pod;
    ($pod=$mlpod) =~ s/\.mlpod$/.pod/ or $pod .= '.pod';
    
    my $dir = s,^([a-z]+)/,, ? $1 : '';
    my ($page,$mandir) = $dir eq 'bin' ? (1=>'MAN1PODS') :
                         $dir eq 'lib' ? (3=>'MAN3PODS') :
                         die "unknown sub [$dir]";
    
    (my $instpod = $_)=~s/\.mlpod$/.pod/;
    $instpod = ( $page==1 ? '$(INST_SCRIPT)/' :
             $page==3 ? '$(INST_LIB)/' :
             die "unknwon page [$page]"
           ) . $instpod;
    
    s/\.\w+$//;
    s/\//::/g;
    my $man = "\$(INST_MAN${page}DIR)/$_.$page";
    
    $ATTR->{depend}{$pod} = $mlpod;
    $ATTR->{depend}{$instpod} = "$pod; $CP \$< \$\@";
    $ATTR->{$mandir}{$instpod} = $man;
    push(@clean_FILES,$pod);
  }
  $ATTR->{clean}{FILES} = join(' ',@clean_FILES);
  $ATTR;
}
