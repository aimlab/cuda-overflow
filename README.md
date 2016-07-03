## Introduction
### original_stackheapoverflow_code
This version is fundamental code. Other is modify based on it
---
### stackversion
Please read it firstly if you want to understand code faster.
#### thread
In this folder, files named 1,2,3 allocate threads in same block. file named 1 allocates stack in local memory, and file named 2 allocates stack in shared memory, so on.
#### block
In this folder, files named 1,2,3 allocate threads in same grid but not same block. file named 1,2,3 is same as above.
#### grid
In this folder, files named 1,2,3 allocate threads in different kernel. file named 1,2,3 is same as above.
### concurrent_heapversion
it is same as stackversion
### otheroverflow
In this folder, it contain integer and structure overflow. the two file is almost same, and both have integer and structure oveflow vulnerablities.
