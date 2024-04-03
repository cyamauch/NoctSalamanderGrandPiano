# Makefile
# This is the basic Makefile for Unix-like systems
# It works for Linux and MacOS

CFLAGS = -O
LDFLAGS =

SRCS = mf2t.c t2mf.c t2mf.h t2mf.fl t2mflex.c yyread.c getopt.h version.h \
	$(wildcard libmidifile/midifile.* libmidifile/Make*) libmidifile/README \
     Makefile $(wildcard makefile.*) $(wildcard tests/*) 

DOCS = README License

LIBS = midifile.o

MF2TOBJS = mf2t.o

T2MFOBJS = t2mf.o t2mflex.o

EXECS = mf2t t2mf
OBJS = $(MF2TOBJS) $(T2MFOBJS)

all: $(EXECS)

mf2t: $(MF2TOBJS) $(LIBS)
	$(CC) $(LDFLAGS) -o mf2t $(MF2TOBJS) $(LIBS)

mf2t.o: midifile.h version.h getopt.h mf2t.c

t2mf: $(T2MFOBJS) $(LIBS)
	$(CC) $(LDFLAGS) -o t2mf $(T2MFOBJS) $(LIBS)

t2mf.o: midifile.h version.h getopt.h t2mf.c

midifile.o: midifile.h midifile.c

#t2mflex.c: t2mf.fl
#	flex -is -Ce t2mf.fl
#	mv lex.yy.c t2mflex.c

t2mflex.o: t2mflex.c t2mf.h

source:
	zip -9 mf2tsrc $(SRCS)

dist:	 $(EXECS) $(DOCS)
	zip -9 mf2t $(EXECS) $(DOCS)

clean:
	rm -f $(EXECS) $(OBJS) $(LIBS) mf2tsrc.zip mf2t.zip
