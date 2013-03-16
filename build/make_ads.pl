#*****************************************************************************
# Copyright (C) All Rights reserved.
#****************************************************************************
# Requirements: Perl 5.005
#****************************************************************************
# Description: Makefile generator
#****************************************************************************


use strict;
use File::Find;
use File::Basename;

my $emake = "Makefile";     # name of target make file, -emake option
my $prjname = "akwaplib";   # name of target, -prj option
my $outname = "wapbrowser"; # name of target file
my $sdkpath = "vmesdk";     # location, -sdkpath option 
my $buildpath = "build";    # -buildpath option

my %BuildDirs;
#$BuildDirs{"ak_apl/m_statemachine"} =1;
my %BuildObs;
#$BuildObs{"AK_APL/m_statemachine/m_state"} = 1;

my %BuildAsmObs;

#for output
my $line;
my $LINE_LENGTH=80;

sub startLine
{
    my $out = shift;
    $line=0;
    print FMAK $out;
}

sub printLine
{
    my $out = shift;
    $line+= length($out);
    if ($line >$LINE_LENGTH)
    {
        print FMAK "\\\n";
	      $line = 0;
    }
    print FMAK $out;
}



sub wanted
{
    if (-f && /^([^ ]+?)\.c$/)
    {    
            
        my @aDirs = split(/\//, $File::Find::dir);
        my $dir;
        my $fulldir;
        foreach $dir (@aDirs)
        {
            if ($dir ne ".")
            {
                $fulldir .= "$dir";
                $BuildDirs{$fulldir} = 1;
                $fulldir .= "/";
            }
        }
        
        $BuildObs{"$fulldir"."$1"} = 1;
    }
}

sub getCFiles
{
    find ({ wanted => \&wanted, no_chdir => 0 }, ".");
}


sub wantedasm
{
    if (-f && (/^([^ ]+?)\.s$/ || /^([^ ]+?)\.S$/))
    {    
        my @aDirs = split(/\//, $File::Find::dir);
        my $dir;
        my $fulldir;
        foreach $dir (@aDirs)
        {
            if ($dir ne ".")
            {
                $fulldir .= "$dir";
                $BuildDirs{$fulldir} = 1;
                $fulldir .= "/";
            }
        }
        
        $BuildAsmObs{"$fulldir"."$1"} = 1;
    }
}

sub getAsmFiles
{
    find (\&wantedasm, ".");
}


sub printMake
{
    my $fname = shift;
    my $prjname = shift;
    my $outname = shift;

    open(FMAK, ">$fname") or die "ERROR: Cannot open $fname!\n";

	  print FMAK "\# Project name\n\n";
	  print FMAK "PROJ = $prjname \n\n";
	  print FMAK "TARGET= $outname\n\n";
	
    print FMAK "\# Pathes and Locations\n\n";

    print FMAK "ifndef SDKPATH\n";
    print FMAK "SDKPATH = $sdkpath\n";
    print FMAK "endif\n";

    print FMAK "ifndef BUILDPATH\n";
    print FMAK "BUILDPATH  = $buildpath\n";
    print FMAK "endif\n";
    
    print FMAK "ifndef M3LIBPATH\n";
    print FMAK "M3LIBPATH  = c:/cygwin/tools\n";
    print FMAK "endif\n";

print FMAK q~

# Flags

INCLUDE    = -I./include -I./arch/include

ENDIANELF	= elf32-little

DEFINE		= -DOS_VME=1

ifdef MEMLEAK
ifeq ($(MEMLEAK),1)
BUILDPATH	:= $(BUILDPATH)ml
TARGET		:= $(TARGET)_ml
DEFINE		+= -DDEBUG_TRACE_MEMORY_LEAK=1
endif
endif

DEFINE		+= -D$(PLATFORM)=1

ifeq ($(CFG),Release)
DEFINE		+= -DRELEASE=1
BUILDPATH	:= $(BUILDPATH)/rel
CFLAGS		= -O2 -apcs /interwork -cpu 4T -W -Ec $(DEFINE) $(INCLUDE)
ASFLAGS   = -apcs /interwork -cpu 4T
else
DEFINE		+= -DDEBUG=1
ifdef CFG
BUILDPATH	:= $(BUILDPATH)/deb
DEFINE		+= -DDEBUG_USE_ASSERT=1
endif
TARGET		:= $(TARGET)d
CFLAGS		= -O2 -g -apcs /interwork -cpu 4T -Ec $(DEFINE) $(INCLUDE)
ASFLAGS   = -g -apcs /interwork -cpu 4T
endif

TARGET		:= $(TARGET).a


# Tools
CC    	= armcc
AS    	= armasm
LD    	= armlink
RM	    = rm -rf
MKDIR	  = mkdir
OBJDUMP	= arm-elf-objdump
OBJCOPY	= arm-elf-objcopy

#Locations
LIBS		= #$(M3LIBPATH)/GNUARM/arm-elf/lib/libc.a  \
		#$(M3LIBPATH)/GNUARM/lib/gcc/arm-elf/3.4.3/libgcc.a

#build rule
.PHONY: clean makedirs maketarget debug release help msi

debug:
	$(MAKE) makedirs CFG=Debug
	$(MAKE) msi CFG=Debug
	$(MAKE) maketarget CFG=Debug

release:
	$(MAKE) makedirs CFG=Release
	$(MAKE) msi CFG=Release
	$(MAKE) maketarget CFG=Release

maketarget: $(BUILDPATH)/$(TARGET)

$(BUILDPATH): 
	-@$(MKDIR) -p $@

~;

startLine("BUILDDIRS = ");

my $path;
my @aPath = sort keys %BuildDirs;
foreach $path (@aPath)
{
    printLine(" \$(BUILDPATH)/$path");
}
print FMAK "\n\$(BUILDDIRS):\n";
print FMAK "\t-@\$(MKDIR) \$@\n";
print FMAK "makedirs: \$(BUILDPATH) \$(BUILDDIRS)\n";

startLine("\nSOBJS = ");
my $sob;
my @saObs = sort keys %BuildAsmObs;
foreach $sob (@saObs)
{
    printLine(" \$(BUILDPATH)/$sob.o");
}
print FMAK "\n";
startLine("\nCOBJS = ");
my $ob;
my @aObs = sort keys %BuildObs;
foreach $ob (@aObs)
{
    printLine(" \$(BUILDPATH)/$ob.o");
}
print FMAK "\n";

print FMAK q~
$(BUILDPATH)/$(TARGET):  $(SOBJS) $(COBJS) $(LIBS)
	@echo ---------------------[build out]----------------------------------	

	
ifeq ($(CFG),Release)
	$(AR) -rsv $(BUILDPATH)/$(TARGET) $(SOBJS) $(COBJS) $(LIBS)
else
	$(AR) -rsv $(BUILDPATH)/$(TARGET) $(SOBJS) $(COBJS) $(LIBS)
endif

#msi: ak_apl/m_statemachine/m_event.h  ak_apl/m_statemachine/m_state.h  ak_apl/m_statemachine/m_state.c

#ak_apl/m_statemachine/m_event.h  ak_apl/m_statemachine/m_state.h  ak_apl/m_statemachine/m_state.c: ak_apl/script_tool/statelist.xls
#	perl ak_apl/script_tool/excelchg.pl ak_apl/script_tool/statelist.xls ak_apl/m_statemachine/states.cfg
#	cd ak_apl;  perl m_statemachine/statecc.pl -f m_statemachine/states.cfg

clean : 
	-@$(RM) $(BUILDPATH)
#	-@$(RM) ak_apl/m_statemachine/m_event.h  ak_apl/m_statemachine/m_state.h  ak_apl/m_statemachine/m_state.c ak_apl/m_statemachine/states.cfg

help:
	@echo "Usage:   make [TARGET] [VARIABLE=XXX]"
	@echo "TARGET:" 
	@echo "         debug:   Builds a debug version, default target"
	@echo "         release: Builds a release version"
	@echo "         clean:   Remove all created objects "
	@echo "VARIABLES:" 
	@echo "         BUILDPATH: Directory of all build objects,"
	@echo "                    e.g. BUILDPATH = c:/build, default: BUILDPATH=build"
	@echo "                    Don't use a backslash!"
	@echo "         PLATFORM:  Type of platform"
	@echo "                    Can be "
	@echo "         MEMLEAK:   build memory leak version"
	@echo "                    MEMLEAK=1 open, MEMLEAK=0 close(default)"
	@echo "         CHIP_INDENTITY: if check the chip"
	@echo "                    CHIP_INDENTITY=1 open(default), CHIP_INDENTITY=0 close"

# Rules


# --------------------------- s -> o
$(BUILDPATH)/%.o:%.s
	@echo ---------------------[$<]----------------------------------
	$(CC) -c $(CFLAGS) -o $@ $<

# ----------------------------- c -> d
$(BUILDPATH)/%.o:%.c
	@echo ---------------------[$<]----------------------------------
	$(CC) -c $(CFLAGS)  -o $@ $<	

~;
}



sub printHelp
{
    print "Syntax:\n";
    print "  make2make.pl [-emake <MAKEFILE>] [-prj <PROJECT>] [-out <OUTNAME>] [-sdkpath <PATH>] [-taskingpath <PATH>] [-buildpath <PATH>]\n";
    print "            -emake <MAKEFILE>: target makefile for elise, default: Makefile\n";
    print "            -prj <PROJECT>: project name, default: elise\n";
    print "            -sdkpath <PATH>: Path of sdk, default: ..\n";
    print "            -taskingpath <PATH>: Path of tasking compiler, default: c:/c166\n";
    print "            -buildpath <PATH>: Path for all build objects, default: build\n";

}

sub handleArgs
{
    my $argc;      
    
    for ($argc=0; $argc<@ARGV; $argc++)
    {
	if ($ARGV[$argc] eq "--help")
	{
	    printHelp();
	    exit(0);   
	}
	elsif ($ARGV[$argc] eq "-emake")
	{            
            $argc++;
	    if ($argc<@ARGV)
	    {
		$emake = $ARGV[$argc];
	    }
	}
	elsif ($ARGV[$argc] eq "-prj")
	{            
            $argc++;
	    if ($argc<@ARGV)
	    {
		$prjname = $ARGV[$argc];
	    }
	}
	elsif ($ARGV[$argc] eq "-out")
	{            
            $argc++;
	    if ($argc<@ARGV)
	    {
		$outname = $ARGV[$argc];
	    }
	}	
	elsif ($ARGV[$argc] eq "-sdkpath")
	{            
            $argc++;
	    if ($argc<@ARGV)
	    {
		$sdkpath = $ARGV[$argc];
		$sdkpath =~ tr/\\/\//;
	    }
	}
	elsif ($ARGV[$argc] eq "-buildpath")
	{            
            $argc++;
	    if ($argc<@ARGV)
	    {
		$buildpath = $ARGV[$argc];
		$buildpath =~ tr/\\/\//;
	    }
	}
	else
	{
	    print "ERROR: Unknown option $ARGV[$argc] !\n";
	    printHelp();
	    exit(-1);
	}
    }      
}

# ----------------------------------------------------------------- main
# ---------------------------------------------------------- handle arguments
handleArgs();
getCFiles();
getAsmFiles();

printMake($emake, $prjname, $outname);
