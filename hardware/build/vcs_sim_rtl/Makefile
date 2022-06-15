default : simv
basedir = ../..



tb = ""  #need override 
pat = "" #need override


# Verilog sources
rtldir = $(basedir)/rtl
# test file
tbdir  = $(basedir)/tb
# include dir
incdir = $(tbdir)/task
# test dir
testdir = $(tbdir)/pat/$(pat)

#tools
getfilelist = $(basedir)/build/tools/getfilelist.py



#--------------------------------------------------------------------
# Build rules
#--------------------------------------------------------------------
VCS = vcs -full64
VCS_OPTS = -notice -PP -line +lint=all,noVCDE +v2k -timescale=1ns/1ns -l build.log -kdb -lca -debug_access+all -R
vcs_clock_period = 2

#--------------------------------------------------------------------
# Build & run the simulator
#--------------------------------------------------------------------
vcs_sim = simv
$(vcs_sim) : filelist
	
	$(VCS) $(VCS_OPTS) +incdir+$(incdir)+$(testdir) -o $(vcs_sim) \
	+define+CLOCK_PERIOD=$(vcs_clock_period) \
	-f filelist $(tbdir)/$(tb).v
	#
	rsync -r  simv *.log *.fsdb *.daidir $(pat)
	rm -rf simv *.log *.fsdb *.daidir csrc
	echo "verdi -nologo -dbdir *.daidir -ssf *.fsdb &" >  $(pat)/v
	chmod u+wrx $(pat)/v


#--------------------------------------------------------------------
# genarate rtl filelist
#--------------------------------------------------------------------
filelist : 
	echo genarate filelist...
	$(getfilelist) -p.v $(rtldir)  



#--------------------------------------------------------------------
# run simulator
#--------------------------------------------------------------------
#run : $(vcs_sim)

# #
# verdi : 
# 	verdi -nologo  -ssf $(tb).fsdb & 


#.PHONY: verdi
.PHONY: filelist


clean:
	
	find . ! -name 'Makefile' -type f -exec rm -f {} +
	find . ! -name 'Makefile' -type d -exec rm -rf {} +
