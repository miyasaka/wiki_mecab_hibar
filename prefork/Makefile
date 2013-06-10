CC	= gcc
INC1     = /usr/local/include
INC2     = /usr/local/apache/include
#LFLAGS = -lpthread -lresolv /usr/local/lib/libmecab.a
LIBDIR = /usr/local/lib/
LIBS = mecab
LIBDIR2 = /usr/local/apache/lib/
LIBS2 = apr-1

TARGET = prefork 
SRC    = prefork.c mecab_analyze.c
OBJ    = prefork.o mecab_analyze.o
DEFS = MIYASAKA
APR_DEFS = _LARGEFILE64_SOURCE 
DBG_DEFS = _NO_UNIT_TEST
SERIAL_DEFS = SERIAL

all:	$(TARGET)

test:	$(TARGET)
	./$(TARGET) -test


$(TARGET): $(OBJ)
	$(CC) $(OBJ) -L $(LIBDIR) -l $(LIBS) -L $(LIBDIR2) -l $(LIBS2) -o $(TARGET)

clean:
	-rm -f $(TARGET) $(OBJ) 

.c.o:
	$(CC) -I $(INC1) -I $(INC2) -D $(DEFS) -D $(DBG_DEFS) -D $(APR_DEFS) -D $(SERIAL_DEFS) -c $(SRC)
