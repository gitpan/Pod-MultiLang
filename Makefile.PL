
use ExtUtils::MakeMaker;
use strict;
my @MLPODFILES = qw( bin/mlpod2html.mlpod
                     bin/mlpod2pod.mlpod
                     lib/Pod/MultiLang.mlpod
                     lib/Pod/MultiLang/Dict.mlpod
                     lib/Pod/MultiLang/Dict/ja.mlpod
                     lib/Pod/MultiLang/Html.mlpod
                    );

my (%MAN1PODS,%MAN3PODS,%DEPEND);
foreach(@MLPODFILES)
{
  my $mlpod = $_;
  my $dir = s,^([a-z]+)/,, ? $1 : '';
  my ($page,$hash) = $dir eq 'bin' ? (1=>\%MAN1PODS) :
                     $dir eq 'lib' ? (3=>\%MAN3PODS) :
                     die "unknown sub [$dir]";
  
  (my $pod = $_)=~s/\.mlpod$/.pod/;
  $pod = ( $page==1 ? '$(INST_SCRIPT)/' :
           $page==3 ? '$(INST_LIB)/' :
           die "unknwon page [$page]"
         ) . $pod;
  
  s/\.\w+$//;
  s/\//::/g;
  my $man = "\$(INST_MAN${page}DIR)/$_.$page";
  $hash->{$pod} = $man;
  $DEPEND{$pod} = $mlpod;
}

WriteMakefile
(
  NAME         => 'Pod::MultiLang',
  VERSION_FROM => 'lib/Pod/MultiLang.pm',
  EXE_FILES    => [qw(bin/mlpod2html bin/mlpod2pod bin/mlpod2html.mlpod bin/mlpod2pod.mlpod)],
  MAN1PODS     => \%MAN1PODS,
  MAN3PODS     => \%MAN3PODS,
  depend       => {
                   '.SUFFIXES' => '.mlpod .pod',
                   '.mlpod.pod' => ';$(PERLRUNINST) bin/mlpod2pod $< > $@',
                   %DEPEND,
                  },
);
