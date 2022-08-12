# ANN_coag_kernel_project

All the scripts needed to train, generate and implement the coagulation kernel of Fabian and Jannis'
Al<sub>2</sub>O<sub>3</sub> burning droplet halo flame case are here, and structured as follows:
- **ANN_train_and_gen** - start by making the necssary executable by running the makefile found at `./projects/ANN_train_and_gen/data_gen`  . `gfortran` is used, adjust if necessary. Then all the data generation, sampling, scaling and training is carried out by the script `ANN_generate.m`. Certain NN related parameters appear at the top of the script and further editing of training parameters can take place by adjusting the `net` object within matlab - check [nftool example](https://uk.mathworks.com/help/deeplearning/ug/body-fat-estimation.html) for the basics. Finally, the trained `net` object will be stored in the `trained_nets` directory using the name specificed at the top of `ANN_generate.m`, along with some shorthand notation for the architecture used to create that net. i.e. `testnet_5:10:1.mat` was named `testnet` by the user and has 5 inputs, 1 hidden layer with 10 nodes and 1 output node. Note, in the matlab notation this net is considered to have 2 layers.



