# Things you might want to put in ENV:
# -DERRAVAIL		have utzoo-compatible error() function and friends
ENV=

# Things you might want to put in TEST:
# -DDEBUG		debugging hooks
# -I.			regexp.h from current directory, not /usr/include
TEST=-I.

# Things you might want to put in PROF:
# -pg			profiler
PROF=

CFLAGS=-O $(ENV) $(TEST) $(PROF)
LDFLAGS=$(PROF)

LIB=libregexp.a
OBJ=regexp.o regsub.o regerror.o
TMP=dtr.tmp

default:	r

try:	try.o $(LIB)
	cc $(LDFLAGS) try.o $(LIB) -o try

# Making timer will probably require putting stuff in $(PROF) and then
# recompiling everything; the following is just the final stage.
timer:	timer.o $(LIB)
	cc $(LDFLAGS) timer.o $(LIB) -o timer

timer.o:	timer.c timer.t.h

timer.t.h:	tests
	sed 's/	/","/g;s/\\/&&/g;s/.*/{"&"},/' tests >timer.t.h

# Regression test.
r:	try tests
	./try <tests		# no news is good news...

$(LIB):	$(OBJ)
	ar cr $(LIB) $(OBJ)

regexp.o:	regexp.c regexp.h regmagic.h
regsub.o:	regsub.c regexp.h regmagic.h

clean:
	rm -f *.o core mon.out gmon.out timer.t.h copy try timer r.*
	rm -f residue rs.* re.1 rm.h re.h ch.soe ch.ps j badcom fig[012]
	rm -f ch.sml fig[12].ps $(LIB)
	rm -rf $(TMP) dtr.*

# the rest of this is unlikely to be of use to you

BITS = r.1 rs.1 re.1 rm.h re.h
OPT=-p -ms

ch.soe:	ch $(BITS)
	soelim ch >$@

ch.sml:	ch $(BITS) smlize splitfigs
	splitfigs ch | soelim | smlize >$@

fig0 fig1 fig2:	ch splitfigs
	splitfigs ch >/dev/null

f:	fig0 fig1 fig2 figs
	groff -Tps -s $(OPT) figs | lpr

fig1.ps:	fig0 fig1
	( cat fig0 ; echo ".LP" ; cat fig1 ) | groff -Tps $(OPT) >$@

fig2.ps:	fig0 fig2
	( cat fig0 ; echo ".LP" ; cat fig2 ) | groff -Tps $(OPT) >$@

fp:	fig1.ps fig2.ps

r.1:	regexp.c splitter
	splitter regexp.c

rs.1:	regsub.c splitter
	splitter regsub.c

re.1:	regerror.c splitter
	splitter regerror.c

rm.h:	regmagic.h splitter
	splitter regmagic.h

re.h:	regexp.h splitter
	splitter regexp.h

PLAIN=COPYRIGHT README Makefile regexp.3 try.c timer.c tests
FIX=regexp.h regexp.c regsub.c regerror.c regmagic.h
DTR=$(PLAIN) $(FIX)

dtr:	r $(DTR)
	rm -rf $(TMP)
	mkdir $(TMP)
	cp $(PLAIN) $(TMP)
	for f in $(FIX) ; do normalize $$f >$(TMP)/$$f ; done
	( cd $(TMP) ; makedtr $(DTR) ) >bookregexp.shar
	( cd $(TMP) ; tar -cvf ../bookregexp.tar $(DTR) )
	rm -rf $(TMP)

ch.ps:	ch Makefile $(BITS)
	groff -Tps $(OPT) ch >$@

copy:	ch.soe ch.sml fp
	makedtr REMARKS ch.sml fig*.ps ch.soe >$@

go:	copy dtr
