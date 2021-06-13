# find-duplicates.bat
A batch script that finds duplicate files using SHA1 comparison in the current working directory and subdirectories.

Caution use in root directory will simply take a long time to hash all files.
## Example output (on desktop):
> 4 duplicates found in "[C:\\...]\test_dir".
> 
> Duplicate file SHA1: 1ce7f9817298fd474e77ef41ad28472a8455056a  
Paths:  
[C:\\...]\test_dir\child\d_file - Copy.txt  
[C:\\...]\test_dir\child\d_file.txt  
> 
> Duplicate file SHA1: 80c8c59a8be1c0f2aad9eb9ad44685ff633c2747  
Paths:  
[C:\\...]\test_dir\b_file - Copy.txt  
[C:\\...]\test_dir\b_file.txt  
>   
> Duplicate file SHA1: f494d38e8bb084892c5c27efc0f1891dc69e9364  
Paths:  
[C:\\...]\test_dir\a_file.txt  
[C:\\...]\test_dir\child\a_file.txt  
> 
> Duplicate file SHA1: HASH_ERROR_FILE_INVALID-SIZE:0  
Paths:  
[C:\\...]\test_dir\data - Copy.txt  
[C:\\...]\test_dir\data.txt  

Does provide actual fully qualified path i.e. rather than [C:\\...].
