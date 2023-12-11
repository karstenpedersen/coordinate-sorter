# Coordinate Sorter

Quicksort implementation using x86-64 assembly to sort (x, y)-coordinates on the y element.

## Get Started

```bash
# generate a file with random numbers
for i in {1..42}; do echo -e "$RANDOM\t$RANDOM"; done > numbers.txt

# build (in /src)
make

# execute ./sorter
./sorter numbers.txt
```

