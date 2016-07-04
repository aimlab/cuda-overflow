# Introduction

### original_stackheapoverflow_code
This version is the fundamental code. Others are modified based on it.

---
### stackversion
Please read it firstly if you want to understand the code faster.
#### thread
In this folder, files named 1,2,3 allocate threads in the same block. File named 1 allocates stack in the local memory, and file named 2 allocates stack in the shared memory, so on.
#### block
In this folder, files named 1,2,3 allocate threads in the same grid but not the same block. Files named 1,2,3 are the same as above.
#### grid
In this folder, files named 1,2,3 allocate threads in different kernels. Files named 1,2,3 are the same as above.

---
### concurrent_heapversion
it is the same as stackversion

---
### otheroverflow
This folder contains code for integer and structure overflow. The two files are almost the same, and both have integer and structure oveflow vulnerablities.
