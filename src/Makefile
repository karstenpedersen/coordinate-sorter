OBJS = allocate.o fileHandling.o parsing.o print.o quicksort.o sorter.o
ASFLAGS = -g

sorter: $(OBJS)
	ld -o sorter $^

# clean build files
.PHONY: clean
clean:
	rm -f *.o sorter 
