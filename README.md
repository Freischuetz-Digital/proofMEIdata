proofMEIdata
============

The proofMEIdata Suite is a set of tools for proofreading MEI encoded XML-files. The suite is setup as eXist-db app.

Code-Mamagement
---------------

We apply the git branching model as described at: http://nvie.com/posts/a-successful-git-branching-model/ and known more commonly as "gitflow".

Building
--------

For building a .XAR package you need apache-ANT installed on your machine. Use the following command for building:

```
ant
```

This wil create a folder 'build' that includes the respective XAR for deployment in eXist-db.

Versioning
----------

We apply semantic versioning as proposed under : http://semver.org
For a description of version differences please see: https://github.com/Freischuetz-Digital/proofMEIdata/releases

License
-------

This package is available under the terms of [GNU GPL-3 License](https://www.gnu.org/licenses/gpl.html) a copy of the license can be found in the repository [gpl-3.0.txt](gpl-3.0.txt).