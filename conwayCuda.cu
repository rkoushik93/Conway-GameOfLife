#include<stdio.h>

__global__ void computeFutureGen(int* current,int* future,int n){
        int col=threadIdx.x+blockIdx.x*blockDim.x;
        int row=threadIdx.y+blockIdx.y*blockDim.y;
        int index=col+row*n;
        //Computing the number of alive neighbors
        int neighAlive=0;
if(col<n && row<n){     //Computation starts only when the thread is within our matrix row & column limit
        //Different cases have to considered before counting the alive neighbors
        if(col==0 && row==0){   //When current node is at top left corner of the matrix
                neighAlive+=current[index+1];   //Neighbor to the right
                neighAlive+=current[index+n];   //Neighbor at the bottom
                neighAlive+=current[index+n+1]; //Neighbor at the bottom right diagonal
        }
        else if(col==0 && row==n-1){    //When current node is at bottom left corner
                neighAlive+=current[index+1];   //Neighbor to the right
                neighAlive+=current[index-n];   //Neighbor directly above
                neighAlive+=current[index-n+1]; //Neighbor at top right diagonal
        }
        else if(col==n-1 && row==0){    //When current node is at top right corner
                neighAlive+=current[index-1];   //Neighbor to the left
                neighAlive+=current[index+n-1]; //Neighbor at bottom left
                neighAlive+=current[index+n];   //Neighbor exactly below
        }
        else if(col==n-1 && row==n-1){  //When current node is at bottom right corner
                neighAlive+=current[index-1];   //Neighbor to the left
                neighAlive+=current[index-n];   //Neighbor exactly above
                neighAlive+=current[index-n-1]; //Neighbor at top left diagonally
        }
        else if(row==0 && col>0 && col<n-1){    //When current node is at top wall excluding the corners
                neighAlive+=current[index-1];   //Neighbor to the left
                neighAlive+=current[index+1];   //Neighbor to the right
                neighAlive+=current[index+n-1]; //Neighbor diagonally left below
                neighAlive+=current[index+n];   //Neighbor exactly below
                neighAlive+=current[index+n+1]; //Neighbor diagonally right below
        }
        else if(row==n-1 && col>0 && col<n-1){  //When current node is on bottom wall excluding the corners
                neighAlive+=current[index-1];   //Neighbor to the left
                neighAlive+=current[index+1];   //Neighbor to the right
                neighAlive+=current[index-n+1]; //Neighbor diagonally right on top
                neighAlive+=current[index-n];   //Neighbor exactly above
                neighAlive+=current[index-n-1]; //Neighbor diagonally left on top
        }
        else if(col==0 && row>0 && row<n-1){    //When current node is on left wall excluding corners
                neighAlive+=current[index+1];   //Neighbor to the right
                neighAlive+=current[index-n];   //Neighbor exactly above
                neighAlive+=current[index-n+1]; //Neighbor diagonally right on top
                neighAlive+=current[index+n];   //Neighbor exactly down
                neighAlive+=current[index+n+1]; //Neighbor diagonally right below
        }
        else if(col==n-1 && row>0 && row<n-1){  //When current node is on right wall excluding corners
                neighAlive+=current[index-1];   //Neighbor to the left
                neighAlive+=current[index-n];   //Neighbor exactly above
                neighAlive+=current[index-n-1]; //Neighbor diagonally left on top
                neighAlive+=current[index+n-1]; //Neighbor diagonally left below
                neighAlive+=current[index+n];   //Neighbor exactly below
        }
        else{   //For all middle elements, within the boundaries described above
                neighAlive+=current[index-1];   //Neighbor to the left
                neighAlive+=current[index+1];   //Neighbor to the right
                neighAlive+=current[index-n-1]; //Neighbor diagonally left on top
                neighAlive+=current[index-n];   //Neighbor exactly above
                neighAlive+=current[index-n+1]; //Neighbor diagonally right on top
                neighAlive+=current[index+n-1]; //Neighbor diagonally left below
                neighAlive+=current[index+n];   //Neighbor exactly below
                neighAlive+=current[index+n+1]; //Neighbor diagonally right below
        }



        //Code block to decide the alive status of a cell based on the number of alive neighbors
        if(current[index]==1 && neighAlive<2)
                future[index]=0;
        else if(current[index]==1 && (neighAlive==2 || neighAlive==3))
                future[index]=1;
        else if(current[index]==1 && neighAlive>3)
                future[index]=0;
        else if(current[index]==0 && neighAlive==3)
                future[index]=1;
        else
                future[index]=0;
}
}


int main(int argc,char** argv){
        int i,j,k;
        int n=0;
        n=atoi(argv[1]);
        int currentGen[n][n];
        int futureGen[n][n];
        dim3 threadsPerBlock(10,10);
        dim3 numBlocks(n/threadsPerBlock.x,n/threadsPerBlock.x);
        int* current;
        int* future;
        float milliseconds=0;
        cudaError_t err;
        cudaEvent_t start,stop;
        cudaEventCreate(&start);
        cudaEventCreate(&stop);

        /*Populating the input matrix currentGen with random 0's
        and 1's using rand() method*/
        for(i=0;i<n;i++)
                for(j=0;j<n;j++)
                        currentGen[i][j]=rand()%2;

        //Initializing the futureGen matrix with all 0's
        for(i=0;i<n;i++)
                for(j=0;j<n;j++)
                        futureGen[i][j]=0;

        //Allocating memory for device copy of current generation matrix
        cudaMalloc((void **) &current,sizeof(int)*n*n);
        err=cudaGetLastError();
        if(err!=cudaSuccess)
                printf("\nERROR after cudaMalloc of current : %s\n\n",cudaGetErrorString(err));

        //Allocating memory for device copy of future generation matrix
        cudaMalloc((void **) &future,sizeof(int)*n*n);
         err=cudaGetLastError();
        if(err!=cudaSuccess)
                printf("\nERROR after cudaMalloc of future: %s\n\n",cudaGetErrorString(err));


        //Copying current generation matrix from host to device
        cudaMemcpy(current,currentGen,sizeof(int)*n*n,cudaMemcpyHostToDevice);
        err=cudaGetLastError();
        if(err!=cudaSuccess)
                printf("\nERROR after cudaMemcpy of currentGen to current: %s\n\n",cudaGetErrorString(err));


        //Displaying the first 10 rows and columns of currentGen matrix
        printf("\nPrinting the alive state of first 10 rows and columns of %dx%d current generation matrix\n",n,n);
        for(i=0;i<10;i++){
                for(j=0;j<10;j++){
                        printf("%d\t",currentGen[i][j]);
                }
                printf("\n");
        }

        cudaEventRecord(start);
        /*Loop for calculating the alive state of the cells after
        10, 100 and 1000 iterations*/
        for(k=1;k<=1000;k++){

        //Calling the kernel
        if(k==1)
                computeFutureGen<<<numBlocks,threadsPerBlock>>>(current,future,n);
        else
                computeFutureGen<<<numBlocks,threadsPerBlock>>>(future,future,n);

        err=cudaGetLastError();
        if(err!=cudaSuccess)
                printf("\nERROR after kernel call: %s\n\n",cudaGetErrorString(err));
        cudaEventRecord(stop);

        //Copying the result from device to host
        cudaMemcpy(futureGen,future,sizeof(int)*n*n,cudaMemcpyDeviceToHost);
        err=cudaGetLastError();
        if(err!=cudaSuccess)
                printf("\nERROR after cudaMemcpy of future to futureGen: %s\n\n",cudaGetErrorString(err));


        //Displaying the first 10 rows and columns of futureGen matrix
        //Display only after 10th, 100th and 1000th iteration
        if(k==10 || k==100 || k==1000){
        printf("\nPrinting the alive state of first 10 rows and columns of %dx%d future generation matrix after %d iterations\n",n,n,k);
        for(i=0;i<10;i++){
                for(j=0;j<10;j++){
                        printf("%d\t",futureGen[i][j]);
                }
                printf("\n");
        }
        cudaEventElapsedTime(&milliseconds,start,stop);
        printf("Time taken for this computation = %f milliseconds\n\n",milliseconds);
        }

        }
        return 0;
}


