CC=flutter
FMT=format

default: fmt

fmt:
	$(CC) $(FMT) .
	$(CC) analyze .

check:
	$(CC) test
