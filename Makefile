CC=flutter
FMT=format

default: get generate check fmt

get:
	$(CC) pub get

generate:
	$(CC) pub run build_runner build --delete-conflicting-outputs;

fmt:
	$(CC) $(FMT) .
	$(CC) analyze .

check:
	$(CC) test

clean:
	$(CC) clean
