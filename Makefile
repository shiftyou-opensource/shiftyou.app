CC=flutter
FMT=format

default: generate check fmt

generate:
	$(CC) pub run build_runner build --delete-conflicting-outputs;

fmt:
	$(CC) $(FMT) .
	$(CC) analyze .

check:
	$(CC) test
