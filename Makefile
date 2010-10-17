
# CC = icc -vec_report0
CC= gcc
# CFLAGS = -w2 -O2  -g -fPIC
CFLAGS = -Wall -O2  -g -fPIC
CXXFLAGS = $(CFLAGS)
# CXX = icpc
CXX = g++
OPTS = 
PG = 
CFLAGS += $(OPTS)
obj=gadgetreader.o read_utils.o
head=read_utils.h gadgetreader.hpp
#Include directories for python and perl
PYINC=/usr/include/python2.6
PERLINC=/usr/lib/perl5/core_perl/CORE

.PHONY: all clean test dist pybind bind

all: libgadread.so

libgadread.so: $(obj)
	$(CC) -shared -Wl,-soname,$@ -o $@  $(obj)
gadgetreader.o: gadgetreader.cpp $(head) read_utils.o
read_utils.o: read_utils.c read_utils.h
test: PGIIhead btest 
	@./btest
	@./PGIIhead test_g2_snap 1 > PGIIhead_out.test 2>/dev/null
	@echo "Errors in PGIIhead output:"
	@diff PGIIhead_out.test PGIIhead_out.txt
PGIIhead: PGIIhead.cpp libgadread.so
btest: btest.cpp libgadread.so
	$(CC) $(CFLAGS) $< -lboost_unit_test_framework -lgadread -L. -o $@

clean: 
	rm $(obj) PGIIhead btest

dist:
	tar -czf GadgetReader.tar.gz Makefile $(head) *.cpp *.c test_g2_snap.*

bind: pybind

python:
	mkdir python
perl:
	mkdir perl

pybind: gadgetreader.i libgadread.so python
	swig -Wall -python -c++ -o python/gadgetreader_python.cxx $< 
	$(CXX) ${CXXFLAGS} -I${PYINC} -shared -Wl,-soname,_gadgetreader.so -L. -lgadread python/gadgetreader_python.cxx -o python/_gadgetreader.so 

#WARNING: Not as functional as python bindings
perlbind: gadgetreader.i libgadread.so perl 
	swig -Wall -perl -c++ -o perl/gadgetreader_perl.cxx $< 
	$(CXX) ${CXXFLAGS} -I${PERLINC} -shared -Wl,-soname,_gadgetreader.so -L. -lgadread perl/gadgetreader_perl.cxx -o perl/_gadgetreader.so 
