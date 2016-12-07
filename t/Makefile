all:
	@echo targets: poly mlton clean

../iconv-poly.sml: ../iconv-poly.sml.in
	@cd .. && make

iconv-poly: ../iconv-poly.sml.in ../iconv-poly.sml t.sml t.mlp
	polyc -o iconv-poly t.mlp

iconv-mlton: ../iconv-mlton.sml t.sml main.sml t.mlb
	mlton -default-ann 'allowFFI true' -output iconv-mlton t.mlb

poly: iconv-poly
	./iconv-poly text.txt

mlton: iconv-mlton
	./iconv-mlton text.txt

clean:
	rm -f iconv-poly iconv-mlton
