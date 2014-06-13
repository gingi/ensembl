#The EnsEMBL API

**[Release 75][release-75]**

A collection of Ensembl API modules maintained at [Github/Ensembl][gh-ens]. This is just a convenience repository that aggregates those modules in one place.

Please see [the main Ensembl page on Github][gh-ens] for more information.

###Contents:

* `ensembl/`: [The EnsEMBL Core API](https://github.com/ensembl/ensembl)
* `ensembl-compara/`: [The EnsEMBL Compara API](https://github.com/ensembl/ensembl-compara)
* `ensembl-funcgen/`: [The EnsEMBL FuncGen API](https://github.com/ensembl/ensembl-funcgen)
* `ensembl-variation/`: [The EnsEMBL Variation API](https://github.com/ensembl/ensembl-variation)
* `ensembl-tools/`: [EnsEMBL tools](https://github.com/ensembl/ensembl-tools)

###Installation

    git clone --recursive git://github.com/gingi/ensembl

This will automatically fetch all the submodules. To do so manually after the repository has been cloned:

    git submodule update --init

###Upgrading to the latest Ensembl sources

    git submodule foreach git pull origin master


###Author
Shiran Pasternak <shiranpasternak@gmail.com>

 [gh-ens]: https://github.com/Ensembl
 [release-75]: http://ensembl.info/blog/2014/02/27/ensembl-75-has-been-released
