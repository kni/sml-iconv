UNAME_O != uname -o
M4 := m4 -P -DOS=${UNAME_O}

.SUFFIXES: .sml .sml.in

all: iconv-poly.sml

.sml.in.sml:
	${M4} $< > $@ || rm -f $@

clean:
	rm -f iconv-poly.sml
