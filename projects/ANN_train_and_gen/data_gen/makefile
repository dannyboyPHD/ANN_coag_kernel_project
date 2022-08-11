OBJ = .
SRC = .
DIR = ..
EXE = gen_input_output_pairs

FC = gfortran 
FLAGS = -O3

OBJECTS  = fabian_data_gen.o

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
	rm -f $(DIR)/gen_input_output_pairs

