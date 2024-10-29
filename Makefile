.PHONY: ascii

default:
	as -o postfix_translator.o src/postfix_translator.s
	ld -o postfix_translator postfix_translator.o
run: default
	./postfix_translator
clean:
	rm -f ./postfix_translator ./postfix_translator.o
grade:
	python3 test/grader.py ./postfix_translator test-cases
debug:
	gcc src/postfix_translator.s -c -g
	ld postfix_translator.o -o postfix_translator
	gdb postfix_translator
ascii:
	./ascii.sh $(filter-out $@,$(MAKECMDGOALS))