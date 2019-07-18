#Encontrar SNPs o variaciones de una muestra partiendo de un mpileup
#Uso:                                                                
# SNPs.pl  [pipleup] [coverage] [% de la variante en escala de 100] > archivo.txt 
# Yina Cobián ######

#Modificación, Febrero 2013, para hacerlo con mpileup de samtools:

#Primer paso: generar mpileup a partir de lo que ya está mapeado, filtrado, etc....:
# samtools mpileup -d 1000000 -f 499_58.fasta aln499_58.mapped.sorted.nodup.bam > mpileup_coco

#El archivo mpileup contiene:
#The columns
#Each line consists of 5 (or optionally 6) tab-separated columns:
#   Sequence identifier
#    Position in sequence (starting from 1)
#    Nucleotide at that position
#    Number of aligned reads covering that position (depth of coverage)
#    Bases at that position from aligned reads
#    Mapping quality of those bases (OPTIONAL)
#Column 5: The bases string
#    . (dot) means a base that matched the reference on the forward strand
#    , (comma) means a base that matched the reference on the reverse strand
#    AGTCN denotes a base that did not match the reference on the forward strand
#    agtcn denotes a base that did not match the reference on the reverse strand
#    +[0-9]+[ACGTNacgtn]+ denotes an insertion of one or more bases
#    -[0-9]+[ACGTNacgtn]+ denotes a deletion of one or more bases
#    ^ (caret) marks the start of a read segment and the ASCII of the character following `^' minus 33 gives the mapping quality
#    $ (dollar) marks the end of a read segment




open (PILEUP, "$ARGV[0]") || die "no puedo abrir $ARGV[0]" ;

my $coverage = $ARGV[1];
my $variante = $ARGV[2];
my $A=0;
my $T=0;
my $G=0;
my $C=0;
my $min;
my $var;
printf "SEQ\tPOS\tCOV\tA\tT\tG\tC\n";
while (<PILEUP>)
        {
        @TABS=(split/\s+/, $_);
        if (@TABS[3] >= $coverage)
                {
                @letras = split(//,@TABS[4]);
                $reference=@TABS[2];
                        foreach $nuc (@letras)
                        {
                        if($nuc=~m/A/i){$A++;}
                        if($nuc=~m/T/i){$T++;}
                        if($nuc=~m/G/i){$G++;}
                        if($nuc=~m/C/i){$C++;}
                        }
                $min=((@TABS[3]*$variante)/100);
                $max=((@TABS[3]*(100-$variante))/100);
                use integer $min;
                use integer $max;
                if ((($A>=$min) && ($A<=$max)) || (($T>=$min) && ($T<=$max)) || (($G>=$min) && ($G<=$max)) || (($C>=$min) && ($C<=$max)))
                        {
                        $var=@TABS[3]-$A-$T-$G-$C;
                        if (@TABS[2]=~m/A/i) {$A=$var;}
                        if (@TABS[2]=~m/T/i) {$T=$var;}
                        if (@TABS[2]=~m/G/i) {$G=$var;}
                        if (@TABS[2]=~m/C/i) {$C=$var;}
                        printf "@TABS[0]\t@TABS[1]\t@TABS[3]\t$A\t$T\t$G\t$C\n";
                        }
                $A=0;
                $T=0;
                $G=0;
                $C=0;
                }
        }
close PILEUP;
