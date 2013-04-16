#The EnsEMBL Perl API
Ported from the official EnsEMBL CVS repository (`cvs.sanger.ac.uk:/cvsroot/ensembl`). Includes:

* The EnsEMBL Core API
* The EnsEMBL Compara API
* The EnsEMBL FuncGen API
* The EnsEMBL Variation API
* The EnsEMBL External API
* EnsEMBL tools

The mirror is maintained manually, including release branches between Version 67 and 71. It does not, unfortunately, retain the entire CVS history in the original repository. However, I've included CVS metadata in case you wish to check out older or more fine-grained file sets.

###Importing CVS revisions

I've tried really hard to make the import of the CVS history automatic. I used [git cvsimport][1], [cvs2git][2], but to no avail. In the meantime, a script (`cvsimport.sh`) is included for automatic import of a specified release branch.

[1]: https://www.kernel.org/pub/software/scm/git/docs/git-cvsimport.html
[2]: http://cvs2svn.tigris.org/cvs2git.html

###Author
Shiran Pasternak <shiranpasternak@gmail.com>