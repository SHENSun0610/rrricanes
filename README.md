
[![minimal R version](https://img.shields.io/badge/R%3E%3D-3.3.3-6666ff.svg)](https://cran.r-project.org/) [![packageversion](https://img.shields.io/badge/Package%20version-0.1.1-orange.svg?style=flat-square)](commits/issue-47) [![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/rrricanes)](https://cran.r-project.org/package=rrricanes) [![Build Status](https://travis-ci.org/timtrice/rrricanes.svg?branch=issue-47)](https://travis-ci.org/timtrice/rrricanes) [![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/timtrice/rrricanes?branch=issue-47&svg=true)](https://ci.appveyor.com/project/timtrice/rrricanes) [![codecov](https://codecov.io/gh/timtrice/rrricanes/branch/issue-47/graph/badge.svg)](https://codecov.io/gh/timtrice/rrricanes)

rrricanes
=========

`rrricanes` is a R library that extracts information from available archives on past and current tropical cyclones. Currently, archives date back to 1998. This is considered "raw data" in the sense that information extracted is from then real-time advisories.

Data can be obtained for cyclones in the north Atlantic (considered the Atlantic Basin) and north-eastern Pacific (the East Pacific Basin from 140°W and eastward, and Central Pacific Basin from 140°W to 180°W).

Getting Started
---------------

Please view the vignette 'Getting Started':

``` r
vignette("getting-started", package = "rrricanes")
```

### Prerequisites

`rrricanes` does require an active internet connection as data is extracted from online archives.

The following R packages are also currently used for data processing:

-   data.table (&gt;= 1.9.6),
-   tidyverse (&gt;= 1.0.0)

On future revisions I will work on minimizing package dependencies if it helps increase processing speed.

### Installing

`rrricanes` is currently only available in GitHub. It can be installed using the `devtools` package:

``` r
devtools::install_github("timtrice/rrricanes")
```

Built With
----------

-   [R 3.2.3](https://www.r-project.org/) - The R Project for Statistical Computing

Contributing
------------

Please read [CONTRIBUTING.md](https://gist.github.com/timtrice/f2a4c2a020c87669178dad27e73bfce1) for details on our code of conduct, and the process for submitting pull requests to us.

Versioning
----------

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/timtrice/rrricanes/tags).

Authors
-------

-   **Tim Trice** - *Initial work* - [timtrice](https://github.com/timtrice)

See also the list of [contributors](https://github.com/timtrice/rrricanes/contributors) who participated in this project.

License
-------

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

Acknowledgments
---------------

-   [Molyneux, James](https://github.com/jimmylovestea)
-   [Rudis, BobRudis](https://github.com/hrbrmstr)
