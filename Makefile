
all: game

game:
	coffee -c -w js/ 

server:
	python3 -m http.server
