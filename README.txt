1. Compile the program using the following command.

	$ nvcc -o conwayCuda conwayCuda.cu

2. The job submission script has been attached under the name
   conwayBash.sh

3. The bash file's last line has the executing statement.

	./conwayCuda <int>

4. The <int> at the last should be replaced by an integer
   value, which specifies the size of the square matrix.

5. The minimum value of this integer should be 10.

6. This integer is the command line argument.

7. The job can be submitted using the following command.

	$ sbatch conwayBash.sh

8. The status of the job can be found using the command.

	$ squeue -u <username>

9. The output will be saved in a file with the name
   conwayCuda.%j.%N.out

10. The output file can be displayed by the following command.

	$ cat <outputfilename.out>

11. The output will consist of the first 10 rows and columns
    of the input currentGen matrix, output futureGen matrix
    after 10, 100 and 1000 iterations, along with the
    respective computation times.

12. The serial code is also attached. It is of the name
    conwaySerial.c

13. The serial code can be compiled on Linux using the command

	gcc conwaySerial.c -o conwaySerial

14. Then use the following command to run it.

	./conwaySerial <integer>

15. Again, the <integer> should be replaced with an integer,
    which is a command line arguement for the matrix size.

16. The serial program will then randomly populate the input
    matrix with 1's and 0's.

17. I have designed the serial program to compute the future
    generation after a single iteration only.

18. This is done to compare its performance with CUDA.