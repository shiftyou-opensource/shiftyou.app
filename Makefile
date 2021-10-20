CC=flutter
FMT=format

default:
	$(CC) pub run build_runner build --delete-conflicting-outputs
	fmt

fmt: $(CC) $(FMT) .
	$(CC) analyze .

check:
	$(CC) test
