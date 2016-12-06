UNAME_O != uname -o
LONG_BIT != getconf LONG_BIT
M4 := m4 -P -DOS=${UNAME_O} -DLONG_BIT=${LONG_BIT}

.SUFFIXES: .sml .sml.in

all: iconv-poly.sml iconv-mlton.sml

.sml.in.sml:
	${M4} $< > $@ || rm -f $@

clean:
	rm -f iconv-poly.sml iconv-mlton.sml
