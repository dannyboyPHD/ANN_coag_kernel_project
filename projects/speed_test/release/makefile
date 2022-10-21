OBJ=.
SRC=../src
DIR=..

EXE = speed_test

FC = gfortran
FLAGS = -O3


MODANN = test_mod.o beta_ann.o
MAIN = speed_test.o
FILES = load_test.o
#PSR_pbe.o

MODULES= $(MODANN)
OBJECTS= $(MODULES) $(FILES) $(MAIN) 

all: $(EXE)

# Build executable & place it in directory
$(EXE): $(OBJECTS)
	$(FC) $(FLAGS) $(addprefix $(OBJ)/,$(OBJECTS)) -o $@
	mv $(EXE) $(DIR)
	@echo Creating $(EXE) ..

$(OBJ)/%.o: $(SRC)/%.f
	$(FC) $(FLAGS) -c $<;

$(OBJ)/%.o: $(SRC)/%.f90
	$(FC) $(FLAGS) -c $<;

clean:
	rm -f $(OBJ)/*.o $(OBJ)/*.mod

veryclean: clean
	rm -f $(DIR)/speed_test

